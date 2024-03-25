#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Export
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Export"
}

helpDescription() {
  echo "Export"
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
  echo "Clean"
}

breakOnConfigFailure() {
  return 0
}

breakOnTestFailure() {
  return 0
}

install() {
  # some cleaning to prepare export
  if [[ "${PREPARE_EXPORT}" = "1" ]]; then
    (
      Log::displayInfo "==> Clean up before export"
      set -x
      rm -f "${BASH_DEV_ENV_ROOT_DIR}/.env" || true
      rm -Rf "${BACKUP_DIR:?}/"* || true
      rm -Rf "/tmp/"* || true
      rm -Rf "${USER_HOME}/.vscode-server" || true
      rm -f "${USER_HOME}/.gitconfig" || true
      rm -f "${USER_HOME}/.ssh/id_rsa" || true
      rm -f "${USER_HOME}/.ssh/config" || true
      rm -f "${USER_HOME}/.saml2aws" || true
      rm -f "${USER_HOME}/.aws/credentials" || true
      rm -f "${USER_HOME}/.aws/config" || true
    )
  else
    Log::displaySkipped "--export option has not been selected"
  fi
}

configure() {
  return 0
}

testInstall() {
  return 0
}

testConfigure() {
  return 0
}
