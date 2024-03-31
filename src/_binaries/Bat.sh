#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Bat
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_githubReleaseScript.tpl")"

scriptName() {
  echo "Bat"
}

fortunes() {
  if command -v bat &>/dev/null; then
    fortunes+=("Bat - Use bat command to pre-visualize one or multiple files")
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
