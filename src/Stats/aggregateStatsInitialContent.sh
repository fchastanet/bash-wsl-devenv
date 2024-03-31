#!/usr/bin/env bash

# @description default aggregateStats file Content
Stats::aggregateStatsInitialContent() {
  local appCount="$1"
  echo "count=0"
  echo "appCount=${appCount}"
  echo "error=0"
  echo "warning=0"
  echo "skipped=0"
  echo "help=0"
  echo "success=0"
  echo "duration=0"
  echo "statusSuccess=0"
}
