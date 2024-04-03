#!/bin/bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/distro
# FACADE
# ROOT_DIR_RELATIVE_TO_BIN_DIR=.

optionSkipDistro=0
optionSkipInstall=0
optionExport=0
optionUpload=0

AUTO_MOUNT_SCRIPT="$(
  cat <<'EOF'
if [[ ! -d "/mnt/wsl/${WSL_DISTRO_NAME}" ]]; then
  mkdir -p "/mnt/wsl/${WSL_DISTRO_NAME}"
  sudo mount --bind / "/mnt/wsl/${WSL_DISTRO_NAME}"
fi
EOF
)"

.INCLUDE "$(dynamicTemplateDir _binaries/_tools/distro.options.tpl)"

downloadDistro() {
  if ! command -v aria2c &>/dev/null; then
    Log::displayInfo "Installing aria2"
    Linux::Apt::installIfNecessary --no-install-recommends aria2
  fi
  local distroImageDir
  distroImageDir="$(getDistroImageDir)"
  local distroImageTargetZip="${TMPDIR:-/tmp}/${distroImageDir}.zip"

  if [[ ! -f "${distroImageDir}/AppxBlockMap.xml" ]]; then
    Log::displayInfo "File ${distroImageDir}/AppxBlockMap.xml does not exist"
    Log::displayInfo "Downloading official ubuntu image from ${DISTRO_URL} ..."
    # https://github.com/aria2/aria2/issues/684
    (
      cd /
      aria2c -c --max-connection-per-server=8 --min-split-size=1M -o "${distroImageTargetZip}" "${DISTRO_URL}"
    )
    Log::displayInfo "Unzipping ubuntu image ..."
    unzip "${distroImageTargetZip}" -d "${distroImageDir}"
  fi

  if [[ ! -f "${distroImageDir}/install.tar" ]]; then
    Log::displayInfo "Extracting install.tar from ubuntu image ..."
    (
      cd "${distroImageDir}" || exit 1
      rm -f Ubuntu_*ARM64.appx
      mv Ubuntu_*_x64.appx Ubuntu.zip
      unzip -p Ubuntu.zip install.tar.gz | gunzip >install.tar
    )

    Log::displayInfo "Cleaning"
    rm -f "${distroImageDir}"/Ubuntu.zip
    rm -f "${distroImageTargetZip}"
  fi

  if [[ ! -f "${distroImageDir}/install.tar" ]]; then
    Log::displayError "File '${distroImageDir}/install.tar' not found"
    exit 1
  fi
}

runWslCmd() {
  local user="${REMOTE_USER:-root}"
  local pwd="${REMOTE_PWD:-/root}"
  wsl.exe -d "${DISTRO_NAME}" -u "${user}" --cd "${pwd}" -- "$@" || return 1
}

installDistro() {
  Log::displayInfo 'Import Base ubuntu image in Wsl'
  local destDistroPath installTarPath
  mkdir -p "${BASE_MNT_C}/Programs"
  local distroImageDir
  distroImageDir="$(getDistroImageDir)"
  destDistroPath="$(wslpath -w "${BASE_MNT_C}/Programs/${DISTRO_NAME}")"
  installTarPath="$(wslpath -w "${distroImageDir}/install.tar")"
  powershell.exe -ExecutionPolicy Bypass -NoProfile \
    -Command "wsl.exe --import \"${DISTRO_NAME}\" \"${destDistroPath}\" \"${installTarPath}\" --version 2"

  Log::displayInfo "Add user ${USERNAME} with default password 'wsl' in new distro"
  runWslCmd useradd -m -s /bin/bash "${USERNAME}"
  runWslCmd usermod -aG sudo "${USERNAME}"
  echo "${USERNAME}:wsl" | runWslCmd chpasswd
}

# mount new distro / folder into current distro
mountDistroFolder() {
  sudo mkdir -p "/mnt/wsl/${DISTRO_NAME}"
  sudo mount -t drvfs "\\\\wsl$\\${DISTRO_NAME}" "/mnt/wsl/${DISTRO_NAME}"
  mkdir -p "/mnt/wsl/${DISTRO_NAME}/home/wsl/fchastanet"
  runWslCmd chown -R "${USERNAME}:${USERGROUP}" /home/wsl/fchastanet
}

getDistroImageName() {
  echo "${DISTRO_URL##*/}"
}

getDistroImageDir() {
  echo "${DISTRO_IMAGE_TARGET_DIR}/$(getDistroImageName)"
}

getDistroFile() {
  echo "$(getDistroImageDir)-${DISTRO_NAME}-export.tar.gz"
}

exportDistro() {
  local distroFile
  distroFile="$(getDistroFile)"
  Log::displayInfo "Terminating wsl distribution ${DISTRO_NAME}"
  wsl.exe --terminate "${DISTRO_NAME}"
  Log::displayInfo "Exporting wsl distribution to ${distroFile}"
  wsl.exe --export "${DISTRO_NAME}" - | gzip -9 >"${distroFile}"
  Log::displaySuccess "Wsl distribution has been exported to ${distroFile}"
}

isDistroSystemdRunning() {
  [[ "$(runWslCmd readlink -f /sbin/init)" = "/usr/lib/systemd/systemd" ]] || return 1
  runWslCmd systemctl status --no-pager &>/dev/null || return 1
}

# @require Linux::requireExecutedAsUser
run() {
  if [[ ! -f "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" ]]; then
    Log::displayError "please create ${BASH_DEV_ENV_ROOT_DIR}/.env.distro using ${BASH_DEV_ENV_ROOT_DIR}/.env.distro.template"
    Log::displayError echo "cp .env.distro.template .env.distro"
    Log::displayError echo "code .env.distro"
    exit 1
  fi

  # shellcheck source=/.env.template
  source "${BASH_DEV_ENV_ROOT_DIR}/.env.distro"
  if [[ ! "${DISTRO_NAME}" =~ ^[-_A-Za-z0-9]+$ ]]; then
    Log::fatal "DISTRO_NAME invalid value : '${DISTRO_NAME}'"
  fi
  if [[ ! "${DISTRO_URL}" =~ ^https://+ ]]; then
    Log::fatal "DISTRO_URL invalid value : '${DISTRO_URL}'"
  fi
  if [[ ! -f "${BASH_DEV_ENV_ROOT_DIR}/profiles/profile.${DISTRO_INSTALL_PROFILE}.sh" ]]; then
    Log::fatal "DISTRO_INSTALL_PROFILE invalid value : file '${BASH_DEV_ENV_ROOT_DIR}/profiles/profile.${DISTRO_INSTALL_PROFILE}.sh' does not exists"
  fi
  # The path where bash-dev-env project will be copied into target distro
  DISTRO_BASH_DEV_ENV_TARGET_DIR="${BASH_DEV_ENV_ROOT_DIR}"
  # shellcheck disable=SC1003
  BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"

  if [[ "${optionSkipDistro}" = "0" ]]; then
    downloadDistro
  fi

  local existingDistroName
  existingDistroName="$(
    WSL_UTF8=1 WSLENV="${WSLENV}":WSL_UTF8 wsl.exe -l -v 2>&1 |
      grep -E "^\s*${DISTRO_NAME}\s" | awk -F ' ' '{print $1}' || true
  )"
  if [[ "${optionSkipDistro}" = "1" ]]; then
    Log::displaySkipped "Distribution ${DISTRO_NAME} installation skipped"
    if [[ "${existingDistroName}" != "${DISTRO_NAME}" ]]; then
      Log::displayError "Distribution ${DISTRO_NAME} not installed"
      exit 1
    fi
  elif [[ "${existingDistroName}" = "${DISTRO_NAME}" ]]; then
    Log::displaySkipped "Distribution ${DISTRO_NAME} already installed"
  else
    installDistro
  fi

  mountDistroFolder

  Log::displayInfo 'Enable automount of / of the distro in /mnt/wsl/<distro> to make distro folder available from other distro'
  echo "${AUTO_MOUNT_SCRIPT}" |
    tee -a "/mnt/wsl/${DISTRO_NAME}/home/wsl/.bashrc" >/dev/null

  Log::displayInfo "Delete folder ${DISTRO_BASH_DEV_ENV_TARGET_DIR} in distro ${DISTRO_NAME}"
  runWslCmd rm -Rf "${DISTRO_BASH_DEV_ENV_TARGET_DIR}/"{*,.*} 2>/dev/null || true

  Log::displayInfo "Prepare archive of current dir ${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
  (cd "${BASH_DEV_ENV_ROOT_DIR}" && tar czf /tmp/bashDevEnv.tgz .)

  Log::displayInfo "Syncing current dir to target distro ${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
  runWslCmd mkdir -p "${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
  runWslCmd chown "${USERNAME}:${USERGROUP}" "${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
  # un-tar file from current distro into the new
  REMOTE_USER=wsl REMOTE_PWD="${DISTRO_BASH_DEV_ENV_TARGET_DIR}" runWslCmd tar xzf "/mnt/wsl/${WSL_DISTRO_NAME}/tmp/bashDevEnv.tgz"

  Log::displayInfo "Fixing rights on target distro ${DISTRO_BASH_DEV_ENV_TARGET_DIR}"
  runWslCmd chown -R "${USERNAME}:${USERGROUP}" "${DISTRO_BASH_DEV_ENV_TARGET_DIR}"

  Log::displayInfo "Copying .env.distro"
  cp -v "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" "/mnt/wsl/${DISTRO_NAME}${DISTRO_BASH_DEV_ENV_TARGET_DIR}/.env"

  local systemdActivated=0
  if isDistroSystemdRunning; then
    systemdActivated=1
  fi
  Log::displayInfo 'pre-configure /etc/wsl.conf in order to activate systemd'
  cp "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/WslDefaultConfig/conf/etc/wsl.conf" "/mnt/wsl/${DISTRO_NAME}/etc/wsl.conf"

  # no need to restart the distro if systemd already active
  if [[ "${systemdActivated}" = "0" ]]; then
    Log::displayInfo "Terminating the distro ${DISTRO_NAME} to enable Systemd"
    wsl.exe --terminate "${DISTRO_NAME}"

    checkDistroTerminated() {
      WSL_UTF8=1 WSLENV="${WSLENV}:WSL_UTF8" wsl.exe -l -v |
        grep "${DISTRO_NAME}" |
        awk -F ' ' '{print $2}' |
        grep -q 'Stopped'
    }
    Retry::parameterized 20 1 "Waiting for distro ${DISTRO_NAME} to terminate" checkDistroTerminated
    Log::displayInfo "Check if systemd has been enabled successfully"
    if ! isDistroSystemdRunning; then
      Log::fatal "Systemd is not running"
    fi
  fi
  local installCmd=(
    ./install -p "${DISTRO_INSTALL_PROFILE}" "${DISTRO_INSTALL_OPTIONS[@]}"
  )
  if [[ "${optionExport}" = "1" ]]; then
    installCmd+=(--prepare-export)
  fi
    
  if [[ "${optionSkipInstall}" = "1" ]]; then
    Log::displayInfo "Install manually using :"
    echo "wsl.exe -d '${DISTRO_NAME}' -u wsl --cd '${DISTRO_BASH_DEV_ENV_TARGET_DIR}' -- ${installCmd[*]}"
  else
    (
      # shellcheck disable=SC2034
      SUDO=""
      # shellcheck disable=SC2034
      SUDOER_FILE_PREFIX="/mnt/wsl/${DISTRO_NAME}"
      .INCLUDE "$(dynamicTemplateDir _includes/sudoerFileManagement.tpl)"

      Log::displayInfo "Installing ... using ${installCmd[*]}"
      REMOTE_USER=${USERNAME} REMOTE_PWD="${DISTRO_BASH_DEV_ENV_TARGET_DIR}" \
        runWslCmd "${installCmd[@]}" || exit 1
    ) || exit 1
  fi

  if [[ "${optionExport}" = "1" ]]; then
    exportDistro
  fi

  if [[ "${optionUpload}" = "1" ]]; then
    local distroFile
    distroFile="$(getDistroFile)"
    if [[ ! -f "" ]]; then
      Log::fatal "missing ${distroFile}, have you forgot --export option ?"
    fi
    Log::displaySkipped "Not implemented yet"
  else
    Log::displaySkipped "upload option was not selected"
  fi

  Log::displaySuccess "Process successful"
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run "$@" &>/dev/null
else
  run "$@"
fi
