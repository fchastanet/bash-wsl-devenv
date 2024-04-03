#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Xvsb
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Xvsb"
}

helpDescription() {
  echo "Xvsb"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  # use to launch headless chrome (used by aws cli)
  # https://stackoverflow.com/a/61043049/3045926
  # Install Xvfb
  Linux::Apt::installIfNecessary --no-install-recommends \
    xvfb

  # Dependencies to make "headless" chrome
  SKIP_APT_GET_UPDATE=1 Linux::Apt::installIfNecessary --no-install-recommends \
    gtk2-engines-pixbuf \
    xorg \
    xvfb

  SKIP_APT_GET_UPDATE=1 Linux::Apt::installIfNecessary --no-install-recommends \
    dbus-x11 \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-base \
    xfonts-cyrillic \
    xfonts-scalable
}

testInstall() {
  local -i failures=0
  Log::displayInfo "Check if xvfb is installed"
  sudo apt-cache show xvfb &>/dev/null || {
    Log::displayError "xvfb not installed"
    ((++failures))
  }
  Log::displayInfo "Check if xvfb is running"
  local xdpyinfoResult
  # capture only stderr: 3>&1 1>/dev/null 2>&3
  xdpyinfoResult="$(xdpyinfo -display :0 3>&1 1>/dev/null 2>&3)" || {
    Log::displayError "xdpyinfo returned that error : ${xdpyinfoResult}"
    ((++failures))
  }
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
