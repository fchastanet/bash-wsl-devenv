#!/bin/bash

REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
CURRENT_DIR="${REAL_SCRIPT_FILE%/*}"

set -o errexit
set -o pipefail

declare file
declare -i installScriptError=0
declare rc=0
while IFS= read -r file; do
  if [[ "${file}" =~ \..+$ ]]; then
    continue
  fi
  rc=0 || true
  output="$(SKIP_REQUIRES=1 "${file}" isInterfaceImplemented 2>&1)" || rc=$?
  if [[ "${rc}" != "0" ]]; then
    echo >&2 "Error on ${file}"
    echo >&2 "${output}"
    ((++installScriptError))
  fi
done < <(find "${CURRENT_DIR}" -path '**/installScripts/*' -type f -perm /a+x)

exit "${installScriptError}"
