#!/bin/bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/distro
# FACADE
# ROOT_DIR_RELATIVE_TO_BIN_DIR=.

optionSkipDistro=0
optionSkipInstall=0
optionExport=0
optionUpload=0

DISTRO_NAME="UbuntuTest"
DISTRO_URL="https://aka.ms/wslubuntu2204"
DISTRO_FILE="/tmp/${DISTRO_NAME}.tar.gz"
UBUNTU_IMAGE_TARGET_DIR="/tmp/Ubuntu-2204"
UBUNTU_IMAGE_TARGET_ZIP="/tmp/Ubuntu-2204.zip"
PROFILE="default"
BASH_DEV_ENV_TARGET_DIR="/home/wsl/projects/bash-dev-env"

.INCLUDE "$(dynamicTemplateDir _binaries/distro.options.tpl)"

downloadDistro() {
  if ! command -v aria2c &>/dev/null; then
    Log::displayInfo "Installing aria2"
    sudo apt-get update
    sudo apt-get install -y aria2
  fi

  if [[ ! -f "${UBUNTU_IMAGE_TARGET_DIR}/AppxBlockMap.xml" ]]; then
    Log::displayInfo "Downloading official ubuntu image from ${DISTRO_URL} ..."
    # https://github.com/aria2/aria2/issues/684
    (
      cd /
      aria2c -c --max-connection-per-server=8 --min-split-size=1M -o "${UBUNTU_IMAGE_TARGET_ZIP}" "${DISTRO_URL}"
    )
    Log::displayInfo "Unzipping ubuntu image ..."
    unzip "${UBUNTU_IMAGE_TARGET_ZIP}" -d "${UBUNTU_IMAGE_TARGET_DIR}"
  fi

  if [[ ! -f "${UBUNTU_IMAGE_TARGET_DIR}/install.tar" ]]; then
    Log::displayInfo "Extracting install.tar from ubuntu image ..."
    (
      cd "${UBUNTU_IMAGE_TARGET_DIR}" || exit 1
      rm -f Ubuntu_*ARM64.appx
      mv Ubuntu_*_x64.appx Ubuntu.zip
      unzip -p Ubuntu.zip install.tar.gz | gunzip >install.tar
    )

    Log::displayInfo "Cleaning"
    rm -f "${UBUNTU_IMAGE_TARGET_DIR}"/Ubuntu.zip
    rm -f "${UBUNTU_IMAGE_TARGET_ZIP}"
  fi

  if [[ ! -f "${UBUNTU_IMAGE_TARGET_DIR}/install.tar" ]]; then
    Log::displayError "File '${UBUNTU_IMAGE_TARGET_DIR}/install.tar' not found"
    exit 1
  fi
}

runWslCmd() {
  local user="${REMOTE_USER:-root}"
  local pwd="${REMOTE_PWD:-/root}"
  wsl.exe -d "${DISTRO_NAME}" -u "${user}" --cd "${pwd}" -- "$@"
}

installDistro() {
  Log::displayInfo 'Import Base ubuntu image in Wsl'
  local destDistroPath installTarPath
  destDistroPath="$(wslpath -w "/c/Programs/${DISTRO_NAME}")"
  installTarPath="$(wslpath -w "${UBUNTU_IMAGE_TARGET_DIR}/install.tar")"
  powershell.exe -ExecutionPolicy Bypass -NoProfile \
    -Command "wsl.exe --import \"${DISTRO_NAME}\" \"${destDistroPath}\" \"${installTarPath}\" --version 2"

  Log::displayInfo 'Add user wsl in new distro'
  runWslCmd useradd -m -s /bin/bash wsl
  runWslCmd usermod -aG sudo wsl
  echo "wsl:wsl" | runWslCmd chpasswd
}

# mount new distro / folder into current distro
mountDistroFolder() {
  sudo mkdir -p "/mnt/wsl/${DISTRO_NAME}"
  sudo mount -t drvfs "\\\\wsl$\\${DISTRO_NAME}" "/mnt/wsl/${DISTRO_NAME}"
  mkdir -p "/mnt/wsl/${DISTRO_NAME}/home/wsl/projects"
}

exportDistro() {
  Log::displayInfo "Exporting wsl distribution"
  wsl.exe --terminate "${DISTRO_NAME}"
  wsl.exe --export "${DISTRO_NAME}" "/tmp/${DISTRO_NAME}.tar"

  Log::displayInfo "Compressing wsl distribution to ${DISTRO_FILE}"
  gzip -9 "/tmp/${DISTRO_NAME}.tar"
}

# @require Linux::requireExecutedAsUser
run() {
  if [[ ! -f "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" ]]; then
    Log::displayError "please create ${BASH_DEV_ENV_ROOT_DIR}/.env.distro using ${BASH_DEV_ENV_ROOT_DIR}/.env.template"
    Log::displayError echo "cp .env.template .env.distro"
    Log::displayError echo "code .env"
    exit 1
  fi

  if [[ "${optionSkipDistro}" = "0" ]]; then
    downloadDistro
  fi

  EXISTING_DISTRO_NAME="$(wsl.exe -l -v 2>&1 | iconv -f UTF-16 | grep -E "^\s*${DISTRO_NAME}\s" | awk -F ' ' '{print $1}' || true)"
  if [[ "${optionSkipDistro}" = "1" ]]; then
    Log::displaySkipped "Distribution ${DISTRO_NAME} installation skipped"
    if [[ "${EXISTING_DISTRO_NAME}" != "${DISTRO_NAME}" ]]; then
      Log::displayError "Distribution ${DISTRO_NAME} not installed"
      exit 1
    fi
  elif [[ "${EXISTING_DISTRO_NAME}" = "${DISTRO_NAME}" ]]; then
    Log::displaySkipped "Distribution ${DISTRO_NAME} already installed"
  else
    installDistro
  fi

  mountDistroFolder

  Log::displayInfo "Syncing current dir to target distro ${BASH_DEV_ENV_TARGET_DIR}"
  set -x
  rm -Rf "/mnt/wsl/${DISTRO_NAME}${BASH_DEV_ENV_TARGET_DIR}" 2>/dev/null || true
  runWslCmd mkdir -p "${BASH_DEV_ENV_TARGET_DIR}"
  runWslCmd chown wsl:wsl "${BASH_DEV_ENV_TARGET_DIR}"
  (cd "${BASH_DEV_ENV_ROOT_DIR}" && tar czf /tmp/bashDevEnv.tgz .)
  cp /tmp/bashDevEnv.tgz "/mnt/wsl/${DISTRO_NAME}/tmp/bashDevEnv.tgz"
  REMOTE_USER=wsl REMOTE_PWD="${BASH_DEV_ENV_TARGET_DIR}" runWslCmd tar xzf /tmp/bashDevEnv.tgz
  runWslCmd chown -R wsl:wsl "${BASH_DEV_ENV_TARGET_DIR}"
  rm -f "/mnt/wsl/${DISTRO_NAME}/tmp/bashDevEnv.tgz"

  Log::displayInfo "Copying .env.distro"
  cp -v "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" "/mnt/wsl/${DISTRO_NAME}${BASH_DEV_ENV_TARGET_DIR}/.env"

  if [[ "${optionSkipInstall}" = "1" ]]; then
    Log::displayInfo "Install manually using :"
    echo "wsl.exe -d '${DISTRO_NAME}' -u wsl --cd '${BASH_DEV_ENV_TARGET_DIR}' -- sudo ./install -p '${PROFILE}'"
  else
    Log::displayInfo "Installing ..."
    REMOTE_USER=wsl REMOTE_PWD="${BASH_DEV_ENV_TARGET_DIR}" runWslCmd sudo ./install -p "${PROFILE}"
  fi

  if [[ "${optionExport}" = "1" ]]; then
    exportDistro
  fi

  if [[ "${optionUpload}" = "1" ]]; then
    if [[ ! -f "${DISTRO_FILE}" ]]; then
      Log::fatal "missing ${DISTRO_FILE}, have you forgot --export option ?"
    fi
    Log::displaySkipped "Not implemented yet"
  else
    Log::displaySkipped "export option was not selected"
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run "$@" &>/dev/null
else
  run "$@"
fi
