#!/usr/bin/env bash

# @description aggregate number of skip/error/... log messages
# and export the result in aggregateStatFile
# @arg $1 aggregateStatFile:String the file in which aggregated
# @arg $2 appCount:int number of app requested to be installed
# @arg $3 statFile:String the current stat file to add to aggregateStatFile
# if it doesn't exist, the file is created with needed variables set to 0
# stats will be saved
Stats::aggregateStats() {
  local aggregateStatFile="$1"
  local appCount="$2"
  local statFile="$3"

  (
    if [[ ! -f "${aggregateStatFile}" ]]; then
      Stats::aggregateStatsInitialContent "${appCount}" >"${aggregateStatFile}"
    fi

    # shellcheck source=src/Stats/logStats.example
    if [[ -f "${statFile}" ]]; then
      source "${statFile}"
    fi
    local newError="${error}"
    local newWarning="${warning}"
    local newSkipped="${skipped}"
    local newHelp="${help}"
    local newSuccess="${success}"
    local newDuration="${duration}"
    local newStatus="${status}"
    # shellcheck source=src/Stats/aggregateStats.example
    source "${aggregateStatFile}"
    if [[ -f "${statFile}" ]]; then
      ((count++)) || true
      if ((newStatus == 0)); then
        ((statusSuccess++)) || true
      fi
      if ((newStatus > 0 || newError > 0)); then
        ((error++)) || true
      fi
      if ((newWarning > 0)); then
        ((warning++)) || true
      fi
      if ((newSkipped > 0)); then
        ((skipped++)) || true
      fi
      if ((newHelp > 0)); then
        ((help++)) || true
      fi
      if ((newSuccess > 0)); then
        ((success++)) || true
      fi
      ((duration = duration + newDuration)) || true
    fi
    (
      echo "count=${count}"
      echo "appCount=${appCount}"
      echo "error=${error}"
      echo "warning=${warning}"
      echo "skipped=${skipped}"
      echo "help=${help}"
      echo "success=${success}"
      echo "duration=${duration}"
      echo "statusSuccess=${statusSuccess}"
    ) >"${aggregateStatFile}"
  )
}
