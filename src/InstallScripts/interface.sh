#!/bin/bash

# @description List the functions needed to implement an install script
# @stdout one function name by line
InstallScripts::interface() {
  echo scriptName
  echo helpDescription

  echo helpVariables
  echo listVariables
  echo defaultVariables
  echo checkVariables

  echo fortunes
  echo dependencies

  echo breakOnTestFailure
  echo breakOnConfigFailure

  echo install
  echo isInstallImplemented

  echo testInstall
  echo isTestInstallImplemented

  echo configure
  echo isConfigureImplemented

  echo testConfigure
  echo isTestConfigureImplemented

  echo cleanBeforeExport
  echo testCleanBeforeExport
  echo isCleanBeforeExportImplemented
}
