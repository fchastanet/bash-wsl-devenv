#!/bin/bash

# @description check if function is empty
# @arg $1 function:Function
# @exitcode 0 if function is considered empty (body with : or true)
InstallScripts::scriptFunctionEmpty() {
  local pattern="^[ \t]+(:|true)"
  [[ "$(declare -f "$1" | sed '3q;d')" =~ ${pattern} && "$(declare -f "$1" | sed '4q;d')" = "}" ]]
}
