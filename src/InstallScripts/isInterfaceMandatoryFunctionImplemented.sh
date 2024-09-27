#!/bin/bash

# @description check that all needed functions are implemented
InstallScripts::isInterfaceMandatoryFunctionImplemented() {
  local -i failures=0
  InstallScripts::isFunctionImplemented helpDescription || ((++failures))
  InstallScripts::isFunctionImplemented helpLongDescription || ((++failures))
  InstallScripts::isFunctionImplemented scriptName || ((++failures))
  InstallScripts::isFunctionImplemented dependencies || ((++failures))
  InstallScripts::isFunctionImplemented listVariables || ((++failures))
  InstallScripts::isFunctionImplemented fortunes || ((++failures))
  InstallScripts::isFunctionImplemented helpVariables || ((++failures))
  InstallScripts::isFunctionImplemented defaultVariables || ((++failures))
  InstallScripts::isFunctionImplemented checkVariables || ((++failures))
  InstallScripts::isFunctionImplemented breakOnConfigFailure || ((++failures))
  InstallScripts::isFunctionImplemented breakOnTestFailure || ((++failures))
  InstallScripts::isFunctionImplemented install || ((++failures))
  InstallScripts::isFunctionImplemented testInstall || ((++failures))
  InstallScripts::isFunctionImplemented configure || ((++failures))
  InstallScripts::isFunctionImplemented testConfigure || ((++failures))
  return "${failures}"
}
