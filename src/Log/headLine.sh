#!/usr/bin/env bash

# @description Display given text on full line with TEST_COLOR style
# @arg $1 text:String text to display
Log::headLine() {
  local type="$1"
  local text="$2"
  local message="${type}   - ${text}"
  if [[ -z "${type}" ]]; then
    message="${text}"
  else
    Log::computeDuration
    message="$(printf '%-7s - %s%s' "${type}" "${LOG_CONTEXT:-}${LOG_LAST_DURATION_STR:-}" "${text}")"
  fi
  echo -e "${__TEST_COLOR}$(UI::textLine "${message}" " ")${__RESET_COLOR}" >&2
}
