#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Java
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Java"
}

helpDescription() {
  echo "Java"
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
  Linux::Apt::installIfNecessary --no-install-recommends \
    openjdk-17-jre
}

testInstall() {
  # shellcheck disable=SC2317
  parseJavaVersion() {
    head -1 | Version::parse
  }
  Version::checkMinimal "java" "--version" "17.0.10" parseJavaVersion || return 1
}

configure() { :; }
testConfigure() { :; }
