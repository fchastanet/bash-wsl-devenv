#!/usr/bin/env bash

helpDescription() {
  echo "Clean"
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
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
configure() { :; }
testInstall() { :; }
testConfigure() { :; }
# jscpd:ignore-end

install() {
  # some cleaning
  Log::displayInfo "==> Clean up"
  sudo apt-get -y autoremove --purge
  sudo apt-get -y clean
  sudo apt-get -y autoclean
}
