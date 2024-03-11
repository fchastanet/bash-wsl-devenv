#!/bin/bash

# @description install or update /etc/profile.d/updateEnv.sh file
installUpdateEnv() {
  CONF_DIR="$1"
  LDAP_LOGIN="$2"
  WINDOWS_PROFILE_DIR="$3"
  # TODO fix
  if [[ ! -f '/etc/profile.d/updateEnv.sh' || "${CONF_DIR}/etc/profile.d/updateEnv.sh" -nt "/etc/profile.d/updateEnv.sh" ]]; then
    sudo@@Install::file -e OVERWRITE_CONFIG_FILES=1 -- "${CONF_DIR}/etc/profile.d" '/etc/profile.d' 'updateEnv.sh' Install::setUserRootCallback
  fi
  if [[ "$(perl -ne 'if (/export LDAP_LOGIN=(.*)/) { print $1 }' "/etc/profile.d/updateEnv.sh")" != "${LDAP_LOGIN}" ]]; then
    sudo sed -i -e "s#export LDAP_LOGIN=.*\$#export LDAP_LOGIN=${LDAP_LOGIN}#g" "/etc/profile.d/updateEnv.sh"
  fi
  sudo sed -i -e "s#WINDOWS_PROFILE_DIR=.*\$#WINDOWS_PROFILE_DIR='${WINDOWS_PROFILE_DIR}'#" "/etc/profile.d/updateEnv.sh"

  # reload env
  set +o errexit
  # shellcheck source=/dev/null
  source "/etc/profile"
  set -o errexit

  # IPCONFIG - which ipconfig.exe does not work when executed as root
  if [[ -z "${IPCONFIG+xxx}" ]]; then
    if Assert::wsl; then
      IPCONFIG="${BASE_MNT_C}/WINDOWS/system32/ipconfig.exe"
      if ! command -v "${IPCONFIG}" >/dev/null 2>&1; then
        IPCONFIG="$(command -v ipconfig.exe 2>/dev/null)"
      fi
    else
      IPCONFIG="${IPCONFIG:-$(command -v ipconfig)}"
    fi
  fi
  if [[ -z "${IPCONFIG:-}" ]]; then
    Log::fatal "command ipconfig.exe not found"
  fi
  command -v "${IPCONFIG}" >/dev/null 2>&1 || Log::fatal "command ipconfig not found"
  export IPCONFIG
}

Engine::Config::initGlobalEnv() {
  # initialize environment variables globally
  if [[ "${INSTALL_UPDATE_ENV:-1}" = "1" ]]; then
    # INSTALL_UPDATE_ENV avoids infinite loop
    installUpdateEnv "${CONF_DIR}" "${SSH_LOGIN}" "${WINDOWS_PROFILE_DIR}"
  fi
}
