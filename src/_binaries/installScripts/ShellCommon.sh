#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/ShellCommon
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellCommon/.inputrc" as inputrc
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellCommon/.dir_colors" as dir_colors
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellCommon/.vimrc" as vimrc

declare -a filesToInstall=(
  inputrc
  dir_colors
  vimrc
)

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "ShellCommon"
}

helpDescription() {
  echo "ShellCommon"
}

helpVariables() {
  true
}

listVariables() {
  true
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  return 0
}

dependencies() {
  return 0
}

breakOnConfigFailure() {
  echo breakOnConfigFailure
}

breakOnTestFailure() {
  echo breakOnTestFailure
}

install() {
  :
}

configure() {
  Conf::installFromEmbed "ShellCommon" "${filesToInstall[@]}" || return 1

  local fileToInstall
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "ShellCommon/.vimrc" "embed_file_vimrc")" || return 1
  SUDO=sudo Install::file \
    "${fileToInstall}" "/root/.vimrc" root root || return 1

  # disable bell
  sudo sed -i -e 's/;set bell-style none/set bell-style none/g' /etc/inputrc
}

testInstall() {
  :
}

testConfigure() {
  local -i failures=0
  Conf::installFromEmbedCheck "${filesToInstall[@]}" || ((failures = failures + $?))
  SUDO=sudo Assert::fileExists /root/.vimrc root root || ((++failures))

  return "${failures}"
}
