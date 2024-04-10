#!/bin/bash

# @description deduce HOME, USER_ID, USERGROUP_ID and USERGROUP from USERNAME
# @env USERNAME String the name of the user
# @set USER_ID String
# @set USERGROUP String
# @set USERGROUP_ID String
# @set USER_SHELL String current user shell
# @set HOME String
Engine::Config::loadUserVariables() {
  # deduce user home and group
  local -a split
  local IFS=':'
  # shellcheck disable=SC2207
  split=($(getent passwd "${USERNAME}"))
  USER_ID="${split[2]}"
  USERGROUP_ID="${split[3]}"
  HOME="${split[5]}"
  USER_SHELL="${split[6]}"
  # shellcheck disable=SC2207
  split=($(getent group "${USERNAME}"))
  USERGROUP="${split[0]}"

  if [[ -z "${USERGROUP}" || -z "${HOME}" ]]; then
    Log::displayError "USERNAME - unable to deduce USERGROUP, HOME from USERNAME"
    return 1
  fi

  export HOME
  export USER_ID
  export USERGROUP_ID
  export USERGROUP
  export USER_SHELL
}
