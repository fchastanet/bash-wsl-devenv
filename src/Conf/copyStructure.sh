#!/bin/bash

Conf::copyStructure() {
  local embedDir="$1"
  local overrideDir="$2"
  local subDir="$3"
  local targetDir="${4:-${USER_HOME}/${subDir}}"

  local configDir
  # shellcheck disable=SC2154
  configDir="$(Conf::getOverriddenDir "${embedDir}" "${overrideDir}")"
  # shellcheck disable=SC2154
  OVERWRITE_CONFIG_FILES=${OVERWRITE_CONFIG_FILES:-1} \
  PRETTY_ROOT_DIR="$(dirname "${embedDir}")" \
  Install::structure "${configDir}/${subDir}" "${targetDir}"
}