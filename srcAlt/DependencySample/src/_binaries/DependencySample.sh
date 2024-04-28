#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/srcAlt/DependencySample/installScripts/DependencySample
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "DependencySample"
}

helpDescription() {
  echo "DependencySample"
}

# jscpd:ignore-start
dependencies() {
  echo "installScripts/MandatorySoftwares"
}
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  echo install
}

testInstall() {
  echo testInstall
}

configure() {
  echo configure
}

testConfigure() {
  echo testConfigure
}
