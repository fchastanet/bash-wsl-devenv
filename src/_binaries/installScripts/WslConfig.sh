#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/WslConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "WslConfig"
}

helpDescription() {
  echo "WslConfig"
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
  return 0
}

breakOnTestFailure() {
  return 0
}

install() {
  return 0
}

configure() {
  sudo hostnamectl set-hostname "${DISTRO_HOSTNAME}"
  SUDO=sudo Dns::addHost "${DISTRO_HOSTNAME}"
  if Assert::wsl && [[ ! -f "/etc/wsl.conf" ]]; then
    SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
      "${CONF_DIR}/etc/wsl.conf" "/etc/wsl.conf" root root "Install::setUserRootCallback"
  fi
}

testInstall() {
  return 0
}

testConfigure() {
  if ! Assert::wsl; then
    return 0
  fi
  if [[ "$(hostnamectl hostname)" != "${DISTRO_HOSTNAME}" ]]; then
    Log::displayError "Hostname ${DISTRO_HOSTNAME} has not been set on this distro"
    ((++failures))
  fi
  if ! Dns::checkHostname "${DISTRO_HOSTNAME}"; then
    Log::displayError "Hostname ${DISTRO_HOSTNAME} is not reachable"
    ((++failures))
  fi
  local -i failures=0
  if ! Assert::fileExists "/etc/wsl.conf" "root" "root"; then
    ((++failures))
    if ! grep -q -E "^root = /mnt/$" "/etc/wsl.conf"; then
      Log::displayError "/etc/wsl.conf does not contains root = /mnt/ instruction"
      ((++failures))
    fi
  fi
  return "${failures}"
}
