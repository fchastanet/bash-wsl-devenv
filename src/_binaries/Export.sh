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
      git config --global --unset user.name || true
      git config --global --unset user.email || true
      rm -Rf "${BACKUP_DIR:?}/"* || true
      rm -Rf "${USER_HOME}/.vscode-server" || true
      rm -f "${USER_HOME}/.ssh/id_rsa" || true
      rm -f "${USER_HOME}/.ssh/config" || true
      rm -f "${USER_HOME}/.ssh/known_hosts.old" || true
      rm -f "${USER_HOME}/.saml2aws" || true
      rm -f "${USER_HOME}/.aws/credentials" || true
      rm -f "${USER_HOME}/.aws/config" || true
      
      deleteFolderExcept() {
        local folder="$1"
        ${SUDO:-} find "${folder}" \
          -mindepth 1 -maxdepth 1 -not -name '.gitkeep' -exec rm -Rf {} ';' || true
      }

      SUDO=sudo deleteFolderExcept "${BASH_DEV_ENV_ROOT_DIR}/megalinter-reports/"
      deleteFolderExcept "${BASH_DEV_ENV_ROOT_DIR}/conf.override/"
      deleteFolderExcept "${BASH_DEV_ENV_ROOT_DIR}/backup/"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/.history" || true
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/pages/docs" || true
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/vendor" || true
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/node_modules" || true
      rm -f "${BASH_DEV_ENV_ROOT_DIR}/TODO.local.md" || true
      cp "${BASH_DEV_ENV_ROOT_DIR}/.env.template" "${BASH_DEV_ENV_ROOT_DIR}/.env" || true
      rm -f "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" || true

      SUDO=sudo deleteFolderExcept "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/megalinter-reports/"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/.history"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/vendor"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/doc"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/bashDoc"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/tests"
      rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/node_modules"
      rm -f "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/commit-msg.md"
    )
    if command -v docker; then
      Log::displayInfo "Cleaning docker system"
      docker system prune -a --volumes --force || true
    fi
  else
    Log::displaySkipped "--export option has not been selected"
  fi
}

testConfigure() {
  local -i failures=0
  if [[ "${PREPARE_EXPORT}" = "1" ]]; then
    if [[ -f "${USER_HOME}/.gitconfig" ]]; then
      if git config --global --get user.name &>/dev/null; then
        Log::displayError "Export - .gitconfig user.name has not been removed"
        ((++failures))
      fi
      if git config --global --get user.email &>/dev/null; then
        Log::displayError "Export - .gitconfig user.email has not been removed"
        ((++failures))
      fi
    fi
    Assert::fileNotExists "${USER_HOME}/.vscode-server" || ((++failures))
    Assert::fileNotExists "${USER_HOME}/.ssh/id_rsa" || ((++failures))
    Assert::fileNotExists "${USER_HOME}/.ssh/config" || ((++failures))
    Assert::fileNotExists "${USER_HOME}/.ssh/known_hosts.old" || ((++failures))
    Assert::fileNotExists "${USER_HOME}/.saml2aws" || ((++failures))
    Assert::fileNotExists "${USER_HOME}/.aws/credentials" || ((++failures))
    Assert::fileNotExists "${USER_HOME}/.aws/config" || ((++failures))

    SUDO=sudo Assert::dirEmpty \
      "${BASH_DEV_ENV_ROOT_DIR}/megalinter-reports/" \
      ".gitkeep" || ((++failures))
    Assert::dirEmpty "${BASH_DEV_ENV_ROOT_DIR}/conf.override/" ".gitkeep" || ((++failures))
    Assert::dirEmpty "${BASH_DEV_ENV_ROOT_DIR}/backup/" ".gitkeep" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/.history" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/pages/docs" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/vendor" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/node_modules" || ((++failures))
    Assert::fileNotExists "${BASH_DEV_ENV_ROOT_DIR}/TODO.local.md" || ((++failures))
    if grep -E -e '^GIT_USERNAME="[^"]+' .env; then
      Log::displayError "${BASH_DEV_ENV_ROOT_DIR}/.env has not been reset"
    fi
    Assert::fileNotExists "${BASH_DEV_ENV_ROOT_DIR}/.env.distro" || ((++failures))

    SUDO=sudo Assert::dirEmpty \
      "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/megalinter-reports/" \
      ".gitkeep" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/.history" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/vendor" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/doc" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/bashDoc" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/tests" || ((++failures))
    Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/node_modules" || ((++failures))
    Assert::fileNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/commit-msg.md" || ((++failures))
  fi
  return "${failures}"
}
