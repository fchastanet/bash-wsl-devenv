#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_tools/findConfigFiles.awk" as findConfigFilesAwk

# shellcheck disable=SC2154
if [[ ! -d "${directory}" ]]; then
  return 1
fi
declare -a findCmd=(
  find "${directory}" -executable -type 'f,l' '('
)
for ext in "${extensions[@]}"; do
  findCmd+=(-name \*."${ext}" -o)
done
unset 'findCmd[-1]'
findCmd+=(')' -printf '%p\n')

# shellcheck disable=SC2154
"${findCmd[@]}" 2>/dev/null |
  awk -v ext="$(printf '%s|' "${extensions[@]}")" -f "${embed_file_findConfigFilesAwk}" |
  sort -t$'\t' -k1,1 -k2,2 | cut -f3-
