#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/bin/doc
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# shellcheck disable=SC2034

DOC_DIR="${BASH_DEV_ENV_ROOT_DIR}/pages"
declare copyrightBeginYear="2020"

.INCLUDE "$(dynamicTemplateDir _binaries/_tools/doc.options.tpl)"

run() {
  if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
    local -a dockerRunCmd=(
      "/bash/bin/doc"
      "${BASH_FRAMEWORK_ARGV_FILTERED[@]}"
    )
    local -a dockerArgvFiltered=(
      -e ORIGINAL_DOC_DIR="${DOC_DIR}"
    )
    # shellcheck disable=SC2154
    Docker::runBuildContainer \
      "${optionVendor:-ubuntu}" \
      "${optionBashVersion:-5.1}" \
      "${optionBashBaseImage:-ubuntu:20.04}" \
      "${optionSkipDockerBuild}" \
      "${optionTraceVerbose}" \
      "${optionContinuousIntegrationMode}" \
      dockerRunCmd \
      dockerArgvFiltered

    return $?
  fi

  #-----------------------------
  # doc generation
  #-----------------------------
  declare ROOT_DIR=/bash
  declare DOC_DIR="${ROOT_DIR}/pages"
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

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
