#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Go
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Go"
}

helpDescription() {
  echo "Go"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  # shellcheck disable=SC2317
  updateGo() {
    (
      cd /opt/update-golang || exit 1
      Retry::default sudo curl \
        -o hash.txt https://raw.githubusercontent.com/udhos/update-golang/master/update-golang.sh.sha256
      sha256sum -c hash.txt || {
        Log::displayError "update-golang sha checksum doesn't match"
      }
      sudo rm -f hash.txt
      mkdir -p "${USER_HOME}/golang"
      Log::displayInfo "Install/update go ..."
      DESTINATION="${USER_HOME}/golang" \
        PROFILED="${USER_HOME}/.bash-dev-env/profile.d/golang.sh" ./update-golang.sh
    )
  }
  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/update-golang" \
    "https://github.com/udhos/update-golang" \
    updateGo \
    updateGo
}

testInstall() {
  Assert::fileExists "${USER_HOME}/.bash-dev-env/profile.d/golang.sh"
  # shellcheck source=/dev/null
  source "${USER_HOME}/.bash-dev-env/profile.d/golang.sh" || return 1
  Version::checkMinimal "go" "version" "1.22.1" || return 1
}

configure() { :; }
testConfigure() { :; }
