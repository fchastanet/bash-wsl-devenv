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
  echo "installScripts/Python"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- if ${__HELP_EXAMPLE}.pre-commit-config.yaml${__RESET_COLOR} file is present, "
  echo -e "${__HELP_EXAMPLE}pre-commit${__RESET_COLOR} will run automatically the tools specified before the commit."
  echo "%"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  if [[ ! -f "${HOME}/.virtualenvs/python3/bin/activate" ]]; then
    Log::displayError "VirtualEnv has not been installed correctly"
    return 1
  fi
  # Load virtualenv
  # shellcheck source=/dev/null
  source "${HOME}/.virtualenvs/python3/bin/activate"

  pip install --user pre-commit
  # update precommit repo
  export PATH="${PATH}:${HOME}/.local/bin"
  pre-commit gc
}

testInstall() {
  local -i failures=0
  export PATH="${PATH}:${HOME}/.local/bin"
  Version::checkMinimal "pre-commit" "--version" "3.6.2" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
