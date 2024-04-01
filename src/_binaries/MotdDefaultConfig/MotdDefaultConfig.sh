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
  echo "Motd"
}

fortunes() {
  if [[ "${SHOW_MOTD}" = "1" ]]; then
    fortunes+=("You can set SHOW_MOTD to 0 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to hide motd")
  else
    fortunes+=("You can set SHOW_MOTD to 1 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to display motd")
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
  sudo chmod 600 /etc/update-motd.d/00-header
  sudo chmod 600 /etc/update-motd.d/10-help-text
  if [[ -f /usr/share/landscape/landscape-sysinfo.wrapper ]]; then
    sudo chmod 600 /usr/share/landscape/landscape-sysinfo.wrapper
  fi

  # update motd cache
  sudo update-motd >/dev/null

}

testConfigure() {
  local -i failures=0
  Assert::fileExecutable "/etc/update-motd.d/00-wsl-header" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/01-wsl-sysinfo" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/03-wsl-automatic-upgrade" || ((++failures))
  Assert::fileNotExecutable "/etc/update-motd.d/10-help-text" || ((++failures))
  Assert::fileNotExecutable "/etc/update-motd.d/00-header" || ((++failures))

  Assert::fileExecutable "/etc/cron.daily/motd" || ((++failures))

  Assert::fileExists "${USER_HOME}/.bash-dev-env/profile.d/motd.sh" || ((++failures))

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
