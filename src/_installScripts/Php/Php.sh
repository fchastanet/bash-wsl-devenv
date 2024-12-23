#!/usr/bin/env bash

helpDescription() {
  echo "PHP is a popular general-purpose scripting language that powers everything from your blog to the most popular websites in the world."
}

# jscpd:ignore-start
fortunes() { :; }
dependencies() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
testConfigure() { :; }
configure() { :; }
# jscpd:ignore-end

install() {
  PACKAGES=(
    php
    php-curl
    # needed by php code sniffer: php-mbstring
    php-mbstring
    # needed by composer : php-xml
    php-xml
  )
  Linux::Apt::installIfNecessary --no-install-recommends "${PACKAGES[@]}"
}

checkPhpModuleExists() {
  if ! php -m | grep -q "$1"; then
    Log::displayError "Php module $1 not found"
    return 1
  fi
  Log::displayInfo "Php module $1 is installed"
}
testInstall() {
  local -i failures=0
  Version::checkMinimal "php" --version "8.3.6" || ((++failures))
  checkPhpModuleExists curl || ((++failures))
  checkPhpModuleExists mbstring || ((++failures))
  checkPhpModuleExists xml || ((++failures))
  return "${failures}"
}
