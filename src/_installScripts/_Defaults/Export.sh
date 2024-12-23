#!/usr/bin/env bash

helpDescription() {
  echo "Export"
}

dependencies() {
  echo "installScripts/Clean"
}

# jscpd:ignore-start
fortunes() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
configure() { :; }
testConfigure() { :; }
# jscpd:ignore-end

cleanBeforeExport() {
  (
    Log::displayInfo "==> Clean up before export"
    rm -Rf "${BACKUP_DIR:?}/"* || true
    find "${HOME}" -name id_rsa -delete || true
    rm -f "${HOME}/.ssh/id_rsa.pub" || true
    rm -f "${HOME}/.ssh/known_hosts.old" || true

    deleteFolderExcept() {
      local folder="$1"
      ${SUDO:-} find "${folder}" \
        -mindepth 1 -maxdepth 1 -not -name '.gitignore' -exec rm -Rf {} ';' || true
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
    rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/.history" || true
    rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/vendor" || true
    rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/doc" || true
    rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/bashDoc" || true
    rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/tests" || true
    rm -Rf "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/node_modules" || true
    rm -f "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/commit-msg.md" || true
  )
}

testCleanBeforeExport() {
  local -i failures=0
  Assert::fileNotExists "${HOME}/.ssh/id_rsa" || ((++failures))
  Assert::fileNotExists "${HOME}/.ssh/id_rsa.pub" || ((++failures))

  SUDO=sudo Assert::dirEmpty \
    "${BASH_DEV_ENV_ROOT_DIR}/megalinter-reports/" \
    ".gitignore" || ((++failures))
  Assert::dirEmpty "${BASH_DEV_ENV_ROOT_DIR}/conf.override/" ".gitignore" || ((++failures))
  Assert::dirEmpty "${BASH_DEV_ENV_ROOT_DIR}/backup/" ".gitignore" || ((++failures))
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
    ".gitignore" || ((++failures))
  Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/.history" || ((++failures))
  Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/vendor" || ((++failures))
  Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/doc" || ((++failures))
  Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/bashDoc" || ((++failures))
  Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/pages/tests" || ((++failures))
  Assert::dirNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/node_modules" || ((++failures))
  Assert::fileNotExists "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework/commit-msg.md" || ((++failures))

  return "${failures}"
}
