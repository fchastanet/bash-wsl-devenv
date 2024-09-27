#!/bin/bash

# @description check that function is implemented
InstallScripts::isFunctionImplemented() {
  local functionName="$1"
  if ! Assert::functionExists "${functionName}"; then
    Log::displayError "$(scriptName) - Function ${functionName} is not implemented"
    return 1
  fi
}
