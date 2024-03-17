#!/bin/bash

# @description install or update /etc/profile.d/updateEnv.sh file
# @env CONF_DIR
# @env LDAP_LOGIN
# @env WINDOWS_PROFILE_DIR
Engine::Config::installUpdateEnv() {
  if [[ "${INSTALL_UPDATE_ENV:-1}" = "1" ]]; then
    # INSTALL_UPDATE_ENV avoids infinite loop
    return 0
  fi

  if [[ ! -f '/etc/profile.d/updateEnv.sh' || "${CONF_DIR}/etc/profile.d/updateEnv.sh" -nt "/etc/profile.d/updateEnv.sh" ]]; then
    # EMBED Install::file AS installFile
    # shellcheck disable=SC2154
    sudo "${embed_file_installFile}" -e OVERWRITE_CONFIG_FILES=1 -- "${CONF_DIR}/etc/profile.d" '/etc/profile.d' 'updateEnv.sh' Install::setUserRootCallback
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
}
