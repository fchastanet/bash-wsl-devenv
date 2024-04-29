#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/BashTools
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/BashTools/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "BashTools"
}

helpDescription() {
  echo "BashTools"
}

fortunes() {
  if [[ -d "${HOME}/fchastanet/bash-tools/bin" ]]; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}cli${__RESET_COLOR} -- tool to easily connect to your containers."
    echo "%"
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}dbImport${__RESET_COLOR} -- tool to import database from aws or remote mysql server."
    echo "%"
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}dbQueryAllDatabases${__RESET_COLOR} -- tool to execute a query on multiple databases."
    echo "%"
  else
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- Run ${__HELP_EXAMPLE}installAndConfigure BashTools${__RESET_COLOR} "
    echo -e "to initialize bash tools (${__HELP_EXAMPLE}cli${__RESET_COLOR}, ${__HELP_EXAMPLE}dbImport${__RESET_COLOR}, ${__HELP_EXAMPLE}dbQueryAllDatabases${__RESET_COLOR}, ...)"
    echo "%"
  fi
}

dependencies() {
  echo "installScripts/PreCommitDefaultConfig"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  Tools::installBashTools
}

testInstall() {
  local -i failures=0
  Assert::dirExists "${HOME}/fchastanet/bash-tools/.git" || ((++failures))
  return "${failures}"
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-tools"
}
testConfigure() {
  local -i failures=0
  Assert::dirExists "${HOME}/.bash-tools" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/bash-tools-dev.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-tools/cliProfiles/default.sh" || ((++failures))
  return "${failures}"
}
