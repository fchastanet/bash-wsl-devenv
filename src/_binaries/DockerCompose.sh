#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/DockerCompose
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_githubReleaseScript.tpl")"

scriptName() {
  echo "DockerCompose"
}

install() {
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/v@latestVersion@/docker-compose-linux-x86_64"
  sudo rm -f /usr/bin/docker-compose || true
  sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
}

testInstall() {
  Version::checkMinimal "docker-compose" --version "2.23.1" || return 1
}
