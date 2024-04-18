#!/bin/bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/bin/loadConfigFiles
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=
# VAR_LOAD_REQUIRES=0
# VAR_LOAD_CONFIG=0
# FACADE

declare dir="$1"
if [[ ! -d "${dir}" ]]; then
  return 1
fi
shift || true
declare -a extensions=("$@")
if ((${#extensions[@]} < 1)); then
  exit 2
fi
declare -a findCmd=(
  find "${dir}" -type 'f,l' '('
)
for ext in "${extensions[@]}"; do
  findCmd+=(-name \*."${ext}" -o)
done
unset 'findCmd[-1]'
findCmd+=(')' -printf '%p\n')

"${findCmd[@]}" 2>/dev/null | awk -v ext="$(printf '%s|' "${extensions[@]}")" '
  .INCLUDE "$(dynamicTemplateDir "_binaries/_tools/loadConfigFiles.awk")"
' | sort -t$'\t' -k1,1 -k2,2 | cut -f3-
