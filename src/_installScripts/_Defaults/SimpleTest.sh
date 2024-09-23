#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Defaults/SimpleTest-hooks" as hooks_dir

helpDescription() {
  echo "SimpleTest"
}

helpLongDescription() {
  echo "SimpleTest"
}

# jscpd:ignore-start
dependencies() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
  echo install
}

testInstall() {
  echo testInstall
}

configure() {
  echo configure
}

testConfigure() {
  echo testConfigure
}
