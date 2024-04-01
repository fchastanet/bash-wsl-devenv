#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Export
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Export"
}

helpDescription() {
  echo "Export"
}

dependencies() {
  echo "Clean"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }

configure() {
  # some cleaning to prepare export
  if [[ "${PREPARE_EXPORT}" = "1" ]]; then
    (
      Log::displayInfo "==> Clean up before export"
      set -x
      rm -Rf "${BACKUP_DIR:?}/"* || true
      rm -Rf "/tmp/"* || true
      rm -Rf "${USER_HOME}/.vscode-server" || true
      rm -f "${USER_HOME}/.gitconfig" || true
      rm -f "${USER_HOME}/.ssh/id_rsa" || true
      rm -f "${USER_HOME}/.ssh/config" || true
      rm -f "${USER_HOME}/.ssh/known_hosts.old" || true
      rm -f "${USER_HOME}/.saml2aws" || true
      rm -f "${USER_HOME}/.aws/credentials" || true
      rm -f "${USER_HOME}/.aws/config" || true
      rmFolderExceptGitkeep() {
        local folder="$1"
        (
          shopt -s extglob
          cd "${folder}"
          rm -Rvf !(.gitkeep)
        ) || true
      }
      rmFolderExceptGitkeep "${BASH_DEV_ENV_ROOT_DIR}/conf.override/" || true
      rmFolderExceptGitkeep "${BASH_DEV_ENV_ROOT_DIR}/logs/" || true
      rmFolderExceptGitkeep "${BASH_DEV_ENV_ROOT_DIR}/megalinter-reports/" || true
      rmFolderExceptGitkeep "${BASH_DEV_ENV_ROOT_DIR}/backup/" || true
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/.history" || true
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/pages/docs" || true
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/vendor" || true
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/node_modules" || true
      rm -f "${BASH_DEV_ENV_ROOT_DIR}/TODO.local.md" || true
      rm -f "${BASH_DEV_ENV_ROOT_DIR}/.env" || true
      rm -f "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" || true

      rmFolderExceptGitkeep "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/megalinter-reports/" || true
      rmFolderExceptGitkeep "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/logs/" || true
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/.history"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/vendor"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/doc"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/bashDoc"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/tests"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/node_modules"
      rm -f "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/commit-msg.md"
    )
  else
    Log::displaySkipped "--export option has not been selected"
  fi
}

testConfigure() { :; }
