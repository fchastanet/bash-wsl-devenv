#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/PreCommit
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "PreCommit"
}

helpDescription() {
  echo "PreCommit"
}

dependencies() {
  # pre-commit is a python package
  echo "Python"
}

fortunes() {
  echo "PreCommit - if .pre-commit-config.yaml file is present, pre-commit will run automatically the tools specified before the commit"
  echo "%"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  if [[ ! -f "${USER_HOME}/.virtualenvs/python3.9/bin/activate" ]]; then
    Log::displayError "VirtualEnv has not been installed correctly"
    return 1
  fi
  # Load virtualenv
  # shellcheck source=/dev/null
  source "${USER_HOME}/.virtualenvs/python3.9/bin/activate"

  pip install --user pre-commit
  # update precommit repo
  pre-commit gc
}

testInstall() {
  local -i failures=0
  Version::checkMinimal "pre-commit" "--version" "3.6.2" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
