#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fd
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Fd/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_githubReleaseScript.tpl")"

scriptName() {
  echo "Fd"
}

fortunes() {
  if command -v fd &>/dev/null; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}fd${__RESET_COLOR} "
    echo -e "is a program to find entries in your filesystem. It is a simple, fast and user-friendly "
    echo -e "alternative to find. While it does not aim to support all of find's powerful functionality, "
    echo -e "it provides sensible (opinionated) defaults for a majority of use cases. "
    echo -e "${__HELP_EXAMPLE}<https://github.com/sharkdp/fd>${__RESET_COLOR}."
    echo "%"
  fi
}

install() {
  SUDO=sudo INSTALL_CALLBACK=Linux::installDeb Github::upgradeRelease \
    "/usr/bin/fd" \
    "https://github.com/sharkdp/fd/releases/download/v@latestVersion@/fd_@latestVersion@_amd64.deb"
}

testInstall() {
  Version::checkMinimal "fd" --version "8.4.0" || return 1
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/fd.zsh" || ((++failures))
  return "${failures}"
}
