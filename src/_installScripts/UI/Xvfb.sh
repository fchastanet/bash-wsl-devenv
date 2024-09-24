#!/usr/bin/env bash

helpDescription() {
  echo "$(scriptName) - installs xvfb"
}

helpLongDescription() {
  helpDescription
  echo "used to launch headless chrome (Eg.: using aws cli)"
  echo "https://stackoverflow.com/a/61043049/3045926"

}

# jscpd:ignore-start
dependencies() { :; }
fortunes() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
configure() { :; }
isConfigureImplemented() { :; }
testConfigure() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
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
