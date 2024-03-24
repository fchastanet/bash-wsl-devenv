#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Anacron
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/etc/cron.weekly/upgrade" as upgrade

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Anacron"
}

helpDescription() {
  echo "Anacron"
}

helpVariables() {
  true
}

listVariables() {
  true
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  return 0
}

dependencies() {
  return 0
}

breakOnConfigFailure() {
  echo breakOnConfigFailure
}

breakOnTestFailure() {
  echo breakOnTestFailure
}

install() {
  Linux::Apt::update
  Linux::Apt::install \
    anacron
}

configure() {

  echo "${USERNAME} ALL= NOPASSWD: /etc/cron.weekly/upgrade" | sudo tee "/etc/sudoers.d/${USERNAME}-upgrade-no-password"
  sudo chmod 0440 "/etc/sudoers.d/${USERNAME}-upgrade-no-password"

  sudo groupadd anacron || true
  sudo adduser "${USERNAME}" anacron || true
  sudo chown root:anacron /var/spool/anacron/
  sudo chmod 755 /var/spool/anacron/

  Log::displayInfo "Install upgrade cron"
  if [[ -z "${PROFILE}" ]]; then
    Log::displayHelp "Please provide a profile to the install command in order to activate automatic upgrade"
  else
    # shellcheck disable=SC2317
    updateCronUpgrade() {
      sudo sed -i -e "s#@COMMAND@#\"${BASH_DEV_ENV_ROOT_DIR}/install\" -p ${PROFILE} --skip-configure --skip-test#" "/etc/cron.weekly/upgrade"
      SUDO=sudo Install::setUserRightsCallback "$@"
    }
    local upgradeFile
    # shellcheck disable=SC2154
    upgradeFile="$(Conf::dynamicConfFile "/etc/cron.weekly/upgrade" "${embed_file_upgrade}")" || return 1
    SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
      "${upgradeFile}" "/etc/cron.weekly/upgrade" root root updateCronUpgrade
  fi
}

testInstall() {
  Assert::commandExists anacron
}

testConfigure() {
  local -i failures=0
  anacron -T || {
    Log::displayError "anacron format not valid"
    ((failures++))
  }
  [[ -f "/etc/cron.weekly/upgrade" ]] || {
    ((failures++))
    Log::displayError "File /etc/cron.weekly/upgrade does not exists"
  }
  grep -q -E -e "install|-p ${PROFILE}" /etc/cron.weekly/upgrade || {
    ((failures++))
    Log::displayError "File /etc/cron.weekly/upgrade content invalid"
  }

  # check if user is part of anacron group
  groups "${USERNAME}" | grep -E ' anacron' || {
    Log::displayError "${USERNAME} is not part of anacron group"
    ((failures++))
  }
  Assert::dirExists /var/spool/anacron/ "root" "anacron" || ((failures++))

  sudo service anacron start || {
    Log::displayError "unable to execute anacron service with user ${USERNAME}"
    ((failures++))
  }

  return "${failures}"
}
