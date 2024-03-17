#!/bin/bash

# @description deduce USER_HOME, USER_ID, USER_GROUP_ID and USER_GROUP from USER_NAME
# @env USER_NAME String the name of the user
# @set USER_ID String
# @set USER_GROUP String
# @set USER_GROUP_ID String
# @set USER_HOME String
Engine::Config::loadUserVariables() {
  # deduce user home and group
  # shellcheck disable=SC2153
  USER_ID="$(getent passwd "${USER_NAME}" | cut -d: -f3)"
  USER_GROUP_ID="$(getent passwd "${USER_NAME}" | cut -d: -f4)"
  USER_GROUP="$(getent group "${USER_GROUP_ID}" | cut -d: -f1)"
  USER_HOME="$(getent passwd "${USER_NAME}" | cut -d: -f6)"

  if [[ -z "${USER_GROUP}" || -z "${USER_HOME}" ]]; then
    Log::displayError "USER_NAME - unable to deduce USER_GROUP, USER_HOME from USER_NAME"
    return 1
  fi

  export USER_HOME
  export USER_ID
  export USER_GROUP_ID
  export USER_GROUP
}
