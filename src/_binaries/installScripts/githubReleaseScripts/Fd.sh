#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fd
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/githubReleaseScripts/_githubReleaseScript.tpl")"

scriptName() {
  echo "Fd"
}

fortunes() {
  if command -v fd &>/dev/null; then
    fortunes+=("Fd -- fd is a program to find entries in your filesystem. It is a simple, fast and user-friendly alternative to find. While it does not aim to support all of find's powerful functionality, it provides sensible (opinionated) defaults for a majority of use cases. - https://github.com/sharkdp/fd")
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
