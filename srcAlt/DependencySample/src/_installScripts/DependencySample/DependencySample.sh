#!/usr/bin/env bash

helpDescription() {
  echo "this is an example that can be used to debug or as a template for other install scripts"
}

dependencies() {
  echo "installScripts/MandatorySoftwares"
}

# jscpd:ignore-start
fortunes() { :; }
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
