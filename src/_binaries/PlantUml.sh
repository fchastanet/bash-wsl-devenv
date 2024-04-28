#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/PlantUml
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "PlantUml"
}

helpDescription() {
  echo "PlantUml"
}

dependencies() {
  echo "installScripts/SdkManager"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

plantumlVersionCallback() {
  # shellcheck source=/dev/null
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
  java -jar /opt/java/plantuml.jar -version | head -1 | Version::parse
}

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    graphviz

  Log::displayInfo "install Plantuml"

  SUDO=sudo SOFT_VERSION_CALLBACK=plantumlVersionCallback Github::upgradeRelease \
    "/opt/java/plantuml.jar" \
    "https://github.com/plantuml/plantuml/releases/download/v@latestVersion@/plantuml-@latestVersion@.jar"
}

testInstall() {
  # ensure java binary is available
  # shellcheck source=/dev/null
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
  Version::checkMinimal "plantumlVersionCallback" -version "1.2023.10" cat || return 1
}

configure() { :; }
testConfigure() { :; }
