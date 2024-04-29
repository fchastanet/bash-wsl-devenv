#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/SdkManager
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_githubReleaseScript.tpl")"

scriptName() {
  echo "SdkManager"
}

dependencies() {
  echo "installScripts/ShellBash"
}

fortunes() {
  echo "$(scriptName) - you can use the command 'sdk install java' to install latest jdk version"
  echo "%"
  echo "$(scriptName) - check https://sdkman.io/sdks to see the list of sdk like "
  echo "scala, gradle, ... that can be easily installed"
  echo '%'
}

install() {
  Linux::Apt::installIfNecessary --no-install-recommends zip
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
  (
    # shellcheck source=/dev/null
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    sdk selfupdate force
    yes | sdk install java || true # exit code of sdk is not reliable
    # exit code can be different than 0 when java already installed
    if ! command -v java &>/dev/null; then
      Log::displayError "java not installed, check above logs"
      return 1
    fi
  ) || {
    Log::displayError "Error while installing java"
    return 1
  }
}

testInstall() {
  (
    local -i failures=0
    # shellcheck source=/dev/null
    source "${HOME}/.sdkman/bin/sdkman-init.sh"

    Assert::commandExists "zip" || ((++failures))
    Version::checkMinimal "sdk" version "5.18.2" || ((++failures))
    Version::checkMinimal "java" --version "21.0.2" || ((++failures))
    return "${failures}"
  ) || return "$?"
}

configure() {
  ln -sf "${HOME}/.sdkman/bin/sdkman-init.sh" "${HOME}/.bash-dev-env/profile.d/sdkman-init.sh"
  chmod +x "${HOME}/.sdkman/bin/sdkman-init.sh"
}

testConfigure() {
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/sdkman-init.sh"
}
