#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/NodeNpm
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/NodeNpm" as node_npm_dir

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

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
  Log::displayInfo "Install ${USER_HOME}/.bash-dev-env/profile.d/n_path.sh"
  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embed_dir_node_npm_dir}" "${CONF_OVERRIDE_DIR}/NodeNpm")"
  OVERWRITE_CONFIG_FILES=1 BACKUP_BEFORE_INSTALL=0 Install::file \
    "${configDir}/.bash-dev-env/profile.d/n_path.sh" "${USER_HOME}/.bash-dev-env/profile.d/n_path.sh"
}

testInstall() {
  local -i failures=0
  Assert::fileExists "${USER_HOME}/.bash-dev-env/profile.d/n_path.sh" || return 1
  # shellcheck source=/conf/NodeNpm/.bash-dev-env/profile.d/n_path.sh
  HOME="${USER_HOME}" source "${USER_HOME}/.bash-dev-env/profile.d/n_path.sh"
  Version::checkMinimal "node" "-v" "20.6.1" || ((++failures))
  Version::checkMinimal "npm" "-v" "10.3.0" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
