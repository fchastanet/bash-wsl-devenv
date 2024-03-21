#!/bin/bash

# @description set sudoer without password temporarily
# @env USERNAME
# @env USER_HOME
# @set SUDOER_CHANGE
Engine::Config::createSudoerFile() {
  local sudoerFile="/etc/sudoers.d/${USERNAME}-bash-dev-env-no-password"

  # create /etc/sudoers.d/userName-bash-dev-env
  local sudoerChange="${USERNAME} ALL=(ALL) NOPASSWD: ${BASH_DEV_ENV_ROOT_DIR}/install,/etc/cron.weekly/upgrade,/usr/sbin/service,${BASH_DEV_ENV_ROOT_DIR}/installScripts"
  if [[ "${sudoerChange}" != "$(sudo cat "${sudoerFile}" 2>/dev/null || echo -n '')" ]]; then
    echo "${sudoerChange}" | sudo tee "${sudoerFile}"
    sudo chmod 0440 "${sudoerFile}"

    echo "this file indicates that sudo has been configured to execute without password" |
      sudo tee "${USER_HOME}/.cron_activated" >/dev/null

    sudo visudo -c -s || {
      Log::displayError "Please check syntax of '${sudoerFile}' before closing this session - 'sudo visudo'"
      return 1
    }
  fi

}
