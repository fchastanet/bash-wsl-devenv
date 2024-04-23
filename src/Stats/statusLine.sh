#!/usr/bin/env bash

# @description display message to reflect last installation status
# @arg $1:statFile
# @arg $2:msg
Stats::statusLine() {
  local statFile="$1"
  local msg="$2"
  if [[ ! -f "${statFile}" ]]; then
    return 0
  fi
  Log::computeDuration
  (
    # shellcheck source=src/Stats/logStats.example
    source "${statFile}" || exit 1

    local color="${__TEST_ERROR_COLOR}"
    local statusMsg
    if [[ "${status}" = "0" ]]; then
      if [[ "${skipped}" = "0" ]]; then
        color="${__SUCCESS_COLOR}"
        statusMsg="SUCCESS - ${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR}${msg} successful"
      fi
    elif [[ "${status}" = "-1" ]]; then
      statusMsg="ABORTED - ${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR}${msg} not executed"
    else
      statusMsg="ERROR   - ${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR}${msg} in error"
    fi
    # overwrite final TEST line
    echo -e "${color}${statusMsg}${__RESET_COLOR}"
  )
}
