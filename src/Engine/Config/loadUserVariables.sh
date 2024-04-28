#!/bin/bash

# @description deduce HOME, USER_ID, USERGROUP_ID and USERGROUP from USERNAME
# @env USERNAME String the name of the user
# @set USER_ID String
# @set USERGROUP String
# @set USERGROUP_ID String
# @set USER_SHELL String current user shell
# @set HOME String
# @env REMOTE String prefix command to run commands remotely
Engine::Config::loadUserVariables() {
  # deduce user home and group
  local -a split
  local IFS=':'
  # shellcheck disable=SC2207
  split=($(${REMOTE:-} getent passwd "${USERNAME}"))
  USER_ID="${split[2]}"
  USERGROUP_ID="${split[3]}"
  HOME="${split[5]}"
  USER_SHELL="${split[6]}"
  USERGROUP="$(${REMOTE:-} id -gn "${USERNAME}")"

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
