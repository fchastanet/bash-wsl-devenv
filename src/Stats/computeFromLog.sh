#!/usr/bin/env bash

# @description extract stats form log
# @arg $1 logFile:String the log file to parse
# @arg $2 status:int the status of the command associated to that log file
# @arg $3 statsFile:String where to write stats
# @arg $4 startDate:String date at which log started
# @stdout output with the format provided by this example src/Stats/aggregateStats.example
# @see src/Stats/aggregateStats.example
Stats::computeFromLog() {
  local logFile="$1"
  local status="$2"
  local statsFile="$3"
  local startDate="$4"
  local endDate
  endDate="$(date +%s)"
  local duration="$((endDate - startDate))"

  local logStatsAwkScript
  logStatsAwkScript="$(
    cat <<'EOF'
{{ includeFile "${BASH_DEV_ENV_ROOT_DIR}/src/Stats/logStats.awk" }}
EOF
  )"

  (
    if [[ -f "${logFile}" ]]; then
      awk -v status="${status}" --source "${logStatsAwkScript}" "${logFile}"
      echo "status=${status}"
      echo "duration=${duration}"
    else
      # not executed
      echo "status=-1"
    fi
  ) >"${statsFile}"
}
