#!/usr/bin/env bash

ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/../.." && pwd -P)
SRC_DIR="$(cd "${ROOT_DIR}/src" && pwd -P)"
FRAMEWORK_DIR="$(cd "${ROOT_DIR}/vendor/bash-tools-framework" && pwd -P)"
export ROOT_DIR SRC_DIR FRAMEWORK_DIR

# shellcheck source=/vendor/bash-tools-framework/src/_includes/_header.sh
source "${FRAMEWORK_DIR}/src/_includes/_header.sh"

declare beforeBuild
computeMd5File() {
  local md5File="$1"
  while IFS= read -r file; do
    md5sum "${file}" >>"${md5File}" 2>&1 || true
  done < <(grep -R "# BIN_FILE" "${SRC_DIR}" | sed -E 's#^.*IN_FILE=(.*)$#\1#' | envsubst)
}

beforeBuild="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
computeMd5File "${beforeBuild}"

cat "${beforeBuild}"

"${ROOT_DIR}/build.sh"

if [[ "$(cat "${beforeBuild}")" = "" ]]; then
  echo >&2 "no bin files were existing before, skip this check"
  exit 0
fi

# exit with code != 0 if at least one bin file has changed
if ! md5sum -c "${beforeBuild}"; then
  echo >&2 "some bin files need to be committed"
  exit 1
fi
