#!/bin/bash

# @description List the functions needed to implement an install script
# @stdout one function name by line
InstallScripts::interface() {
  echo installScript_helpDescription
  echo installScript_helpVariables
  echo installScript_listVariables
  echo installScript_defaultVariables
  echo installScript_checkVariables
  echo installScript_fortunes
  echo installScript_dependencies
  echo installScript_breakOnConfigFailure
  echo installScript_breakOnTestFailure
  echo installScript_install
  echo installScript_configure
  echo installScript_test
}
