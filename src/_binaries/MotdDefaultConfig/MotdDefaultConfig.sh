#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/MotdDefaultConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/MotdDefaultConfig/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "MotdDefaultConfig"
}

helpDescription() {
  echo "MotdDefaultConfig"
}

dependencies() {
  echo "Anacron"
}

fortunes() {
  if [[ "${SHOW_MOTD}" = "1" ]]; then
    echo "You can set SHOW_MOTD to 0 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to hide motd"
    echo "%"
  else
    echo "You can set SHOW_MOTD to 1 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to display motd"
    echo "%"
  fi
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
# jscpd:ignore-end

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  # shellcheck disable=SC2154
  SUDO=sudo Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    "etc" \
    "/etc"

  # disable some parts
  sudo chmod 600 \
    /etc/update-motd.d/00-header \
    /etc/update-motd.d/10-help-text \
    /etc/update-motd.d/50-motd-news \
    /etc/update-motd.d/90-updates-available \
    /etc/update-motd.d/91-contract-ua-esm-status \
    /etc/update-motd.d/91-release-upgrade \
    /etc/update-motd.d/92-unattended-upgrades \
    /etc/update-motd.d/95-hwe-eol ||
    true

  if [[ -f /usr/share/landscape/landscape-sysinfo.wrapper ]]; then
    sudo chmod 600 /usr/share/landscape/landscape-sysinfo.wrapper
  fi
  sudo sed -i -E \
    -e "s#^BASH_DEV_ENV_LOGS_DIR=.*\$#BASH_DEV_ENV_LOGS_DIR=${LOGS_DIR}#" \
    /etc/update-motd.d/03-wsl-automatic-upgrade

  # update motd cache
  sudo update-motd >/dev/null

}

testConfigure() {
  local -i failures=0
  Assert::fileExecutable "/etc/update-motd.d/00-wsl-header" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/01-wsl-sysinfo" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/03-wsl-automatic-upgrade" || ((++failures))
  if grep -E -q '^BASH_DEV_ENV_LOGS_DIR=/invalid$' /etc/update-motd.d/03-wsl-automatic-upgrade; then
    Log::displayError "/etc/update-motd.d/03-wsl-automatic-upgrade contain invalid path"
    ((++failures))
  fi
  Assert::fileNotExecutable "/etc/update-motd.d/10-help-text" root root || ((++failures))
  Assert::fileNotExecutable "/etc/update-motd.d/00-header" root root || ((++failures))

  Assert::fileExecutable "/etc/cron.daily/motd" || ((++failures))

  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/motd.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/motd.zsh" || ((++failures))

  if ! sudo update-motd >/dev/null; then
    Log::displayWarning "motd not working"
    ((++failures))
  fi
  if [[ -z "$(sudo update-motd)" ]]; then
    Log::displayWarning "motd is empty"
    ((++failures))
  fi
  return "${failures}"
}
