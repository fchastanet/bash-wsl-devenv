#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Saml2Aws
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_githubReleaseScript.tpl")"

scriptName() {
  echo "Saml2Aws"
}

dependencies() {
  echo "installScripts/AwsCli"
}

fortunes() {
  echo "use aws-login alias to log to aws using saml2aws (see https://github.com/Versent/saml2aws)"
  if ! command -v saml2aws &>/dev/null; then
    printf "\ninstall it using 'installAndConfigure Saml2Aws"
  fi
  echo "%"
}

# @see https://github.com/fchastanet/my-documents/blob/master/HowTo/Saml2Aws.md
saml2awsInstallCallback() {
  sudo tar xzvf "$1" -C /usr/local/bin saml2aws
  sudo chmod +x /usr/local/bin/saml2aws
  hash -r
  sudo rm -f "$1"
}

install() {
  SUDO=sudo INSTALL_CALLBACK=saml2awsInstallCallback Github::upgradeRelease \
    /usr/local/bin/saml2aws \
    "https://github.com/Versent/saml2aws/releases/download/v@latestVersion@/saml2aws_@latestVersion@_linux_amd64.tar.gz"
}

testInstall() {
  Version::checkMinimal "saml2aws" --version "2.36.10" || return 1
}
