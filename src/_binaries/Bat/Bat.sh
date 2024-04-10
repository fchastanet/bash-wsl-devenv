#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Bat
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Bat/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_githubReleaseScript.tpl")"

scriptName() {
  echo "Bat"
}

fortunes() {
  if command -v bat &>/dev/null; then
    echo "$(scripName) - Use bat command to pre-visualize one or multiple files"
    echo "%"
    echo "$(scripName) - alias h allows to display command help using bat, try 'h cp'"
    echo "%"
    
    if [[ "${USER_SHELL}" = "/usr/bin/zsh" ]]; then
      echo "$(scripName) - command with --help will automatically be displayed with bat"
      echo "%"
    fi
  else
    echo "Run 'installAndConfigure Bat' -- to initialize Bat (file pre-visualization tool)"
    echo "%"
  fi
  
}

install() {
  SUDO=sudo INSTALL_CALLBACK=Linux::installDeb Github::upgradeRelease \
    "/usr/bin/bat" \
    "https://github.com/sharkdp/bat/releases/download/v@latestVersion@/bat_@latestVersion@_amd64.deb"
}

testInstall() {
  Version::checkMinimal "bat" --version "0.22.1" || return 1
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testConfigure() {
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/bat.sh"
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/bat.zsh"
}