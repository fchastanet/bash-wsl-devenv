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

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}n${__RESET_COLOR} -- tool to easily switch from one ${__HELP_EXAMPLE}node${__RESET_COLOR} version to another."
  echo "%"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  if [[ ! -d "${HOME}/n" ]]; then
    # -y avoid interactive
    # -n no automatic bash profile install
    Retry::default curl --fail -L https://git.io/n-install |
      N_PREFIX="${HOME}/n" bash -s -- -y -n latest
  else
    (
      # shellcheck disable=SC2030
      PATH="${PATH}":"${HOME}/n/bin"
      # update n
      N_PREFIX="${HOME}/n" n-update -y
      # update node
      N_PREFIX="${HOME}/n" "${HOME}/n/bin/n" latest
    ) || return 1
  fi

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testInstall() {
  local -i failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/n_path.sh" || ((++failures))
  # shellcheck source=src/_binaries/NodeNpm/conf/.bash-dev-env/profile.d/n_path.sh
  source "${HOME}/.bash-dev-env/profile.d/n_path.sh" || ((++failures))
  Version::checkMinimal "node" "-v" "20.6.1" || ((++failures))
  Version::checkMinimal "npm" "-v" "10.3.0" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
