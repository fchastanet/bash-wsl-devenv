#!/usr/bin/env bash

# @description aggregate number of skip/error/... log messages
# and export the result in aggregateStatFile
# @arg $1 statFile:String the current stat file to add to aggregateStatFile
# @arg $2 appCount:int number of app requested to be installed
# @arg $@ statFiles:String[] the files in which each step stats have been aggregated aggregated
# if it doesn't exist, the file is created with needed variables set to 0
# stats will be saved
Stats::aggregateGlobalStats() {
  local aggregateStatFile="$1"
  local appCount="$2"
  shift 2 || true
  local -a statFiles=("$@")

  (
    if [[ ! -f "${aggregateStatFile}" ]]; then
      Stats::aggregateStatsInitialContent "${appCount}" >"${aggregateStatFile}"
    fi
    # shellcheck source=src/Stats/aggregateStats.example
    source "${aggregateStatFile}"

    local -i globalError=0
    local -i globalWarning=0
    local -i globalSkipped=0
    local -i globalHelp=0
    local -i globalSuccess=0
    local -i globalStatus=0
    ((globalDuration = duration)) || true
    for statFile in "${statFiles[@]}"; do
      if [[ ! -f "${statFile}" ]]; then
        continue
      fi
      # shellcheck source=src/Stats/logStats.example
      source "${statFile}"

      # all statuses need to be 0 for global status to be O
      globalError=$((globalError || error))
      globalWarning=$((globalWarning || warning))
      globalSkipped=$((globalSkipped || skipped))
      globalHelp=$((globalHelp || help))
      globalSuccess=$((globalSuccess || success))
      globalStatus=$((globalStatus || status))
      globalDuration=$((globalDuration + duration))
    done
    # shellcheck source=src/Stats/aggregateStats.example
    source "${aggregateStatFile}"
    ((count++)) || true
    if ((globalStatus == 0)); then
      ((statusSuccess++)) || true
    fi
    if ((globalStatus > 0 || globalError > 0)); then
      ((error++)) || true
    fi
    if ((globalWarning > 0)); then
      ((warning++)) || true
    fi
    if ((globalSkipped > 0)); then
      ((skipped++)) || true
    fi
    if ((globalHelp > 0)); then
      ((help++)) || true
    fi
    if ((globalSuccess > 0)); then
      ((success++)) || true
    fi
    (
      echo "count=${count}"
      echo "appCount=${appCount}"
      echo "error=${error}"
      echo "warning=${warning}"
      echo "skipped=${skipped}"
      echo "help=${help}"
      echo "success=${success}"
      echo "duration=${globalDuration}"
      echo "statusSuccess=${statusSuccess}"
    ) >"${aggregateStatFile}"
  )
}
