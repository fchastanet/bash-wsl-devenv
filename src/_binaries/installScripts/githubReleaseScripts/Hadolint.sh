#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Hadolint
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/githubReleaseScripts/_githubReleaseScript.tpl")"

scriptName() {
  echo "Hadolint"
}

install() {
  SUDO=sudo Github::upgradeRelease \
    "/usr/local/bin/hadolint" \
    "https://github.com/hadolint/hadolint/releases/download/v@latestVersion@/hadolint-Linux-x86_64"
}

testInstall() {
  Version::checkMinimal "hadolint" --version "2.12.0" || return 1
}
