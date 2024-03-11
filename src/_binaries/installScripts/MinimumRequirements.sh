#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/MinimumRequirements
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

installScript_helpDescription() {
  echo "MinimumRequirements"
}

installScript_helpVariables() {
  true
}

installScript_listVariables() {
  true
}

installScript_defaultVariables() {
  true
}

installScript_checkVariables() {
  true
}

installScript_fortunes() {
  return 0
}

installScript_dependencies() {
  return 0
}

installScript_breakOnConfigFailure() {
  return 0
}

installScript_breakOnTestFailure() {
  return 0
}

installScript_install() {
  return 0
}

installScript_configure() {
  return 0
}

installScript_test() {
  return 0
}
