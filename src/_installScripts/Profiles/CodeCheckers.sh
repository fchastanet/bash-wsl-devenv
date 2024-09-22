#!/usr/bin/env bash

helpDescription() {
  echo "Install several kind of code checkers"
}

dependencies() {
  echo "installScripts/ComposerDependencies"
  echo "installScripts/NodeDependencies"
  echo "installScripts/ShFmt"
  echo "installScripts/Hadolint"
  echo "installScripts/Shellcheck"
}

# jscpd:ignore-start
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
install() { :; }
testInstall() { :; }
# jscpd:ignore-end
