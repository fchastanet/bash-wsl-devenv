#!/bin/bash

# @description trap function responsible to compute and display stats after each script execution
# @arg $1 logFile:String
# @arg $2 statFile:String
# @arg $3 startDate:String date at which log started
Stats::computeStatsTrap() {
  local status="$?"
  local logFile="$1"
  local statFile="$2"
  local startDate="$3"
  local endDate
  endDate="$(date +%s)"
  Stats::computeFromLog "${logFile}" "${status}" "$((endDate - startDate))" >"${statFile}"
  return "${status}"
}
