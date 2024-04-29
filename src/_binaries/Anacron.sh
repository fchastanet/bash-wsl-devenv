#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Anacron
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Anacron"
}

helpDescription() {
  echo "Anacron"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}anacron${__RESET_COLOR} is the daemon that completes cron for computers that are not on at all times, check out some examples:"
  echo -e "${__HELP_EXAMPLE}ls -al /etc/cron.{hourly,daily,weekly,monthly,yearly}${__RESET_COLOR}"
  echo "%"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    anacron
}

testInstall() {
  Assert::commandExists anacron
}

configure() {
  sudo groupadd anacron || true
  sudo adduser "${USERNAME}" anacron || true
  sudo chown root:anacron /var/spool/anacron/
  sudo chmod 755 /var/spool/anacron/
}

testConfigure() {
  local -i failures=0
  anacron -T || {
    Log::displayError "anacron format not valid"
    ((failures++))
  }

  # check if user is part of anacron group
  groups "${USERNAME}" | grep -E ' anacron' || {
    Log::displayError "${USERNAME} is not part of anacron group"
    ((failures++))
  }
  Assert::dirExists /var/spool/anacron/ "root" "anacron" || ((failures++))

  if ! sudo service anacron start; then
    Log::displayError "unable to execute anacron service with user ${USERNAME}"
    ((failures++))
  fi

  return "${failures}"
}
