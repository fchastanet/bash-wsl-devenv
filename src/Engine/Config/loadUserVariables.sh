#!/bin/bash

# @description deduce USER_HOME, USER_ID, USERGROUP_ID and USERGROUP from USERNAME
# @env USERNAME String the name of the user
# @set USER_ID String
# @set USERGROUP String
# @set USERGROUP_ID String
# @set USER_HOME String
Engine::Config::loadUserVariables() {
  # deduce user home and group
  local -a split
  local IFS=':'
  # shellcheck disable=SC2207
  split=($(getent passwd "${USERNAME}"))
  USER_ID="${split[2]}"
  USERGROUP_ID="${split[3]}"
  USER_HOME="${split[5]}"
  # shellcheck disable=SC2207
  split=($(getent group "${USERNAME}"))
  USERGROUP="${split[0]}"

  if [[ -z "${USERGROUP}" || -z "${USER_HOME}" ]]; then
    Log::displayError "USERNAME - unable to deduce USERGROUP, USER_HOME from USERNAME"
    return 1
  fi

  export USER_HOME
  export USER_ID
  export USERGROUP_ID
  export USERGROUP
}
