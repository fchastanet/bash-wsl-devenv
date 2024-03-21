#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Clean
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Clean"
}

helpDescription() {
  echo "Clean"
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
  # some cleaning
  Log::displayInfo "==> Clean up"
  sudo apt-get -y autoremove --purge
  sudo apt-get -y clean
  sudo apt-get -y autoclean
}

configure() {
  return 0
}

testInstall() {
  return 0
}

testConfigure() {
  return 0
}
