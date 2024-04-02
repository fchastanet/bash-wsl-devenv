#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fortune
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Fortune/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Fortune"
}

helpDescription() {
  echo "Fortune"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() {
  if [[ "${SHOW_FORTUNES}" = "1" ]]; then
    # shellcheck disable=SC2016
    echo "You can set SHOW_FORTUNES to 0 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to hide fortunes"
    echo "%"
  fi
}
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::update
  Linux::Apt::install \
    cowsay \
    lolcat \
    fortune-mod
}

testInstall() {
  Assert::commandExists fortune
  Assert::commandExists lolcat
  Assert::commandExists cowsay
}

configure() {
  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embed_dir_conf_dir}" "${CONF_OVERRIDE_DIR}/Fortune")"

  Log::displayInfo "prepare fortunes database file"
  sudo touch /etc/fortune-help-commands
  sudo chown "${USERNAME}:${USERGROUP}" /etc/fortune-help-commands

  Log::displayInfo "Install cron to update fortunes"
  if [[ -z "${PROFILE}" ]]; then
    Log::displayHelp "Please provide a profile to the install command in order to activate automatic fortune generation"
  else
    # shellcheck disable=SC2317
    updateCronFortune() {
      local -a cmd=(
        sudo
        -i -n
        -u "${USERNAME}"
        "${BASH_DEV_ENV_ROOT_DIR}/bin/fortune"
        -p "${PROFILE}"
      )
      sudo sed -i -E -e "s#@COMMAND@#(cd '${BASH_DEV_ENV_ROOT_DIR}' \&\& ${cmd[*]} \&>'${BASH_DEV_ENV_ROOT_DIR}/logs/fortune-job.log')#" \
        "/etc/cron.d/bash-dev-env-fortune"
      SUDO=sudo Install::setUserRightsCallback "$@"
    }

    SUDO=sudo OVERWRITE_CONFIG_FILES=1 BACKUP_BEFORE_INSTALL=0 Install::file \
      "${configDir}/etc/cron.d/bash-dev-env-fortune" "/etc/cron.d/bash-dev-env-fortune" \
      root root updateCronFortune
    sudo chmod +x "/etc/cron.d/bash-dev-env-fortune"
  fi

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists /etc/fortune-help-commands || ((++failures))
  if [[ -n "${PROFILE}" ]]; then
    Log::displayInfo "checking Fortune cron configuration"
    Assert::fileExecutable "/etc/cron.d/bash-dev-env-fortune" "root" "root" || ((++failures))
    if ! grep -q -E -e "fortune -p ${PROFILE}" /etc/cron.d/bash-dev-env-fortune; then
      ((failures++))
      Log::displayError "File /etc/cron.d/bash-dev-env-fortune content invalid"
    fi
  fi
  Assert::fileExists "${USER_HOME}/.bash-dev-env/interactive.d/displayFortunes.sh" || ((++failures))
  return "${failures}"
}
