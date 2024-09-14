#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/bin/doc
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# VAR_LOAD_REQUIRES=0
# VAR_LOAD_CONFIG=0
# shellcheck disable=SC2034

declare copyrightBeginYear="2020"

.INCLUDE "$(dynamicTemplateDir _binaries/_tools/doc.options.tpl)"

runContainer() {
  local image="scrasnups/build:bash-tools-ubuntu-5.3"
  local -a dockerRunCmd=(
    "/bash/bin/doc"
    "${BASH_FRAMEWORK_ARGV_FILTERED[@]}"
  )

  if ! docker inspect --type=image "${image}" &>/dev/null; then
    docker pull "${image}"
  fi
  # run docker image
  local -a localDockerRunArgs=(
    --rm
    -e KEEP_TEMP_FILES="${KEEP_TEMP_FILES:-0}"
    -e BATS_FIX_TEST="${BATS_FIX_TEST:-0}"
    -e ORIGINAL_DOC_DIR="${BASH_DEV_ENV_ROOT_DIR}/pages"
    -w /bash
    -v "${BASH_DEV_ENV_ROOT_DIR}:/bash"
    --entrypoint /usr/local/bin/bash
  )
  # shellcheck disable=SC2154
  if [[ "${optionContinuousIntegrationMode}" = "0" ]]; then
    localDockerRunArgs+=(
      -e USER_ID="${USER_ID:-1000}"
      -e GROUP_ID="${GROUP_ID:-1000}"
      --user "www-data:www-data"
      -v "/tmp:/tmp"
      -it
    )
  fi
  if [[ -d "${FRAMEWORK_ROOT_DIR}" ]]; then
    localDockerRunArgs+=(
      -v "$(cd "${FRAMEWORK_ROOT_DIR}" && pwd -P):/bash/vendor/bash-tools-framework"
    )
  fi

  # shellcheck disable=SC2154
  if [[ "${optionTraceVerbose}" = "1" ]]; then
    set -x
  fi
  docker run \
    "${localDockerRunArgs[@]}" \
    "${image}" \
    "${dockerRunCmd[@]}"
  set +x
}

generateDoc() {
  # shellcheck disable=SC2154
  if [[ "${optionTraceVerbose}" = "1" ]]; then
    set -x
  fi
  local ROOT_DIR=/bash
  local DOC_DIR="${ROOT_DIR}/pages"
  # copy other files
  cp "${ROOT_DIR}/README.md" "${DOC_DIR}/README.md"
  sed -i -E \
    -e '/<!-- remove -->/,/<!-- endRemove -->/d' \
    -e 's#https://fchastanet.github.io/bash-dev-env/#/#' \
    -e 's#^> \*\*_TIP:_\*\* (.*)$#> [!TIP|label:\1]#' \
    "${DOC_DIR}/README.md"

  cp -R "${ROOT_DIR}/docs" "${DOC_DIR}/docs"

  Log::displayStatus "Doc generated in ${ORIGINAL_DOC_DIR} folder"
}

run() {
  if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
    runContainer
  else
    generateDoc
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
