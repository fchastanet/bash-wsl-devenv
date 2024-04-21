#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Go
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Go/conf" as conf_dir

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
  filterLatestNonBetaVersion() {
    jq -r '.[].files[].version' |
      sort |
      uniq |
      grep -v -E 'go[0-9\.]+(beta|rc)' |
      sed -E -e 's/go//' |
      sort -V |
      tail -1
  }
  # shellcheck disable=SC2317
  installGo() {
    local downloadedArchive="$1"
    Log::displayInfo "Install/update go ..."
    mkdir -p "${HOME}/golang"
    tar xvzf "${downloadedArchive}" -C "${HOME}/golang"
  }
  FILTER_LAST_VERSION_CALLBACK=filterLatestNonBetaVersion \
    INSTALL_CALLBACK=installGo \
    Web::upgradeRelease \
    "${HOME}/golang/go/bin/go" \
    "https://go.dev/dl/?mode=json" \
    "https://storage.googleapis.com/golang/go@latestVersion@.linux-amd64.tar.gz" \
    version
}

testInstall() {
  local failures=0
  Assert::fileExists "${HOME}/golang/go/bin/go" || ((++failures))
  Version::checkMinimal "${HOME}/golang/go/bin/go" "version" "1.22.2" || ((++failures))
  return "${failures}"
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
  ln -sfv "${HOME}/golang/go/bin/go" "${HOME}/go/bin/go"
  ln -sfv "${HOME}/golang/go/bin/gofmt" "${HOME}/go/bin/gofmt"
}
testConfigure() {
  local failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/golang.sh" || ((++failures))
  # shellcheck source=/dev/null
  source "${HOME}/.bash-dev-env/profile.d/golang.sh" || ((++failures))
  Version::checkMinimal "go" "version" "1.22.2" || ((++failures))
  return "${failures}"
}
