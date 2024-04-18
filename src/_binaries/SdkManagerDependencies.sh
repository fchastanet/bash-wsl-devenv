#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/SdkManagerDependencies
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_githubReleaseScript.tpl")"

scriptName() {
  echo "SdkManagerDependencies"
}

install() {
  sdk install gradle
}

testInstall() {
 (
    local -i failures=0
    # shellcheck source=/dev/null
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    Version::checkMinimal "gradle" --version "8.7" || ((++failures))
    return "${failures}"
  ) || return "$?"
}
