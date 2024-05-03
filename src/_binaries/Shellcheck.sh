#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Shellcheck
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_githubReleaseScript.tpl")"

scriptName() {
  echo "Shellcheck"
}

shellcheckInstallCallback() {
  local archive="$1"
  local targetFile="$2"
  local version="$3"
  sudo tar -xvJf "${archive}" \
    --strip-components=1 \
    -C "$(dirname "${targetFile}")" \
    "shellcheck-v${version}/shellcheck"
  sudo chmod +x "${targetFile}"
  rm -f "${archive}" || true
}

install() {
  SUDO=sudo INSTALL_CALLBACK=shellcheckInstallCallback Github::upgradeRelease \
    /usr/local/bin/shellcheck \
    "https://github.com/koalaman/shellcheck/releases/download/v@latestVersion@/shellcheck-v@latestVersion@.linux.x86_64.tar.xz"
}

testInstall() {
  Version::checkMinimal "shellcheck" --version "0.10.0" || return 1
}
