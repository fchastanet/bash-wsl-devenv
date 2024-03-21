#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Motd
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Motd"
}

helpDescription() {
  echo "Motd"
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
  if [[ "${SHOW_MOTD}" = "1" ]]; then
    fortunes+=("You can set SHOW_MOTD to 0 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to hide motd")
  else
    fortunes+=("You can set SHOW_MOTD to 1 in '${BASH_DEV_ENV_ROOT_DIR}/.env' to display motd")
  fi
}

dependencies() {
  echo "Anacron"
}

breakOnConfigFailure() {
  return 0
}

breakOnTestFailure() {
  return 0
}

install() {
  Linux::Apt::update
  PACKAGES=(
    # /usr/share/update-notifier/notify-updates-outdated needed by motd
    update-notifier-common
  )
  Linux::Apt::install "${PACKAGES[@]}"
}

configure() {
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${CONF_DIR}/etc/update-motd.d/00-wsl-header" "/etc/update-motd.d/00-wsl-header" \
    Install::setRootExecutableCallback
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${CONF_DIR}/etc/update-motd.d/01-wsl-sysinfo" "/etc/update-motd.d/01-wsl-sysinfo" \
    Install::setRootExecutableCallback
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${CONF_DIR}/etc/update-motd/03-wsl-automatic-upgrade" "/etc/update-motd.d/03-wsl-automatic-upgrade" \
    Install::setRootExecutableCallback
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${CONF_DIR}/etc/cron.daily/motd" "/etc/cron.daily/motd" \
    Install::setRootExecutableCallback

  # disable some parts
  sudo chmod 600 /etc/update-motd.d/00-header
  sudo chmod 600 /etc/update-motd.d/10-help-text
  if [[ -f /usr/share/landscape/landscape-sysinfo.wrapper ]]; then
    sudo chmod 600 /usr/share/landscape/landscape-sysinfo.wrapper
  fi

  # update motd cache
  sudo update-motd >/dev/null

}

testInstall() {
  return 0
}

testConfigure() {
  local -i failures=0
  Assert::fileExecutable "/etc/update-motd.d/00-wsl-header" "root" "root" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/01-wsl-sysinfo" "root" "root" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/03-wsl-automatic-upgrade" "root" "root" || ((++failures))
  Assert::fileNotExecutable "/etc/update-motd.d/10-help-text" "root" "root" || ((++failures))
  Assert::fileNotExecutable "/etc/update-motd.d/00-header" "root" "root" || ((++failures))

  Assert::fileExecutable "/etc/cron.daily/motd" "root" "root" || ((++failures))

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
