#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/CodeCheckers
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "CodeCheckers"
}

helpDescription() {
  echo "CodeCheckers"
}

dependencies() {
  # Go is needed by shfmt
  echo "Go"
  # Python is needed by shfmt-py
  echo "Python"
  echo "NodeDependencies"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  Linux::Apt::update
  Linux::Apt::install \
    shellcheck
  if [[ -f "${USER_HOME}/.virtualenvs/python3.9/bin/activate" ]]; then
    # shellcheck source=/dev/null
    source "${USER_HOME}/.virtualenvs/python3.9/bin/activate"
    pip install --user shfmt-py
  else
    Log::displaySkipped "VirtualEnv has not been installed correctly"
    return 1
  fi
}

testInstall() {
  local -i failures=0
  Version::checkMinimal "shellcheck" --version "0.7.0" || ((++failures))
  Version::checkMinimal "shfmt" --version "3.7.0" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
