#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/NodeNpm
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/NodeNpm/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "NodeNpm"
}

helpDescription() {
  echo "NodeNpm"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  if [[ ! -d "${USER_HOME}/n" ]]; then
    # -y avoid interactive
    # -n no automatic bash profile install
    Retry::default curl --fail -L https://git.io/n-install |
      N_PREFIX="${USER_HOME}/n" bash -s -- -y -n latest
  else
    # update node
    N_PREFIX="${USER_HOME}/n" "${USER_HOME}/n/bin/n" latest
  fi
  
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testInstall() {
  local -i failures=0
  Assert::fileExists "${USER_HOME}/.bash-dev-env/profile.d/n_path.sh" || ((++failures))
  # shellcheck source=src/_binaries/NodeNpm/conf/.bash-dev-env/profile.d/n_path.sh
  HOME="${USER_HOME}" source "${USER_HOME}/.bash-dev-env/profile.d/n_path.sh" || ((++failures))
  Version::checkMinimal "node" "-v" "20.6.1" || ((++failures))
  Version::checkMinimal "npm" "-v" "10.3.0" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
