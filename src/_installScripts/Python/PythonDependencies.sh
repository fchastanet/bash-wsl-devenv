#!/usr/bin/env bash

helpDescription() {
  echo "Install Python dependencies"
  echo "- Precommit - A framework for managing and maintaining multi-language pre-commit hooks."
  echo "- sshuttle - where transparent proxy meets VPN meets ssh"
}

dependencies() {
  # pre-commit and sshuttle are python packages
  echo "installScripts/Python"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- if ${__HELP_EXAMPLE}.pre-commit-config.yaml${__RESET_COLOR} file is present, "
  echo -e "${__HELP_EXAMPLE}pre-commit${__RESET_COLOR} will run automatically the tools specified before the commit."
  echo "%"
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- sshuttle allows you to create a VPN connection using only SSH."
  echo "%"
}

# jscpd:ignore-start
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
configure() { :; }
testConfigure() { :; }
# jscpd:ignore-end

install() {
  if [[ ! -f "${HOME}/.venvs/python3/bin/activate" ]]; then
    Log::displayError "VirtualEnv has not been installed correctly"
    return 1
  fi
  # Load virtualenv
  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate"

  pip install pre-commit
  pip install sshuttle
  # update precommit repo
  export PATH="${PATH}:${HOME}/.local/bin"
  pre-commit gc
}

testInstall() {
  local -i failures=0
  # Load virtualenv
  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate" || ((++failures))
  Version::checkMinimal "pre-commit" "--version" "3.6.2" || ((++failures))
  Version::checkMinimal "sshuttle" "--version" "1.1.1" || ((++failures))
  return "${failures}"
}
