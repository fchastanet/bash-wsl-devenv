#!/usr/bin/env bash

# @description recapitulate important log messages
# @stdout the important log messages
Stats::logRecapitulative() {
  local logFile="$1"

  local logRecapitulativeAwkScript
  logRecapitulativeAwkScript="$(
    cat <<'EOF'
{{ includeFile "${BASH_DEV_ENV_ROOT_DIR}/src/Stats/logRecapitulative.awk" }}
EOF
  )"

  if [[ -f "${logFile}" ]]; then
    awk --source "${logRecapitulativeAwkScript}" "${logFile}" | uniq
  fi
}
