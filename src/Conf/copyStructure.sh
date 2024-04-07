#!/bin/bash

# @description copy folder structure to target directory
# merge embedDir with overridden directory if provided and available
# @arg $1 embedDir:String the path embedded
# @arg $2 overrideDir:String the path overridden
# @arg $3 subDir:String the sub-directory to copy from embedDir and/or overrideDir
# @arg $4 targetDir:String the target directory (default: ${USER_HOME}/${subDir})
# @env SUDO String allows to use custom sudo prefix command
# @env USER_HOME used for default value of targetDir arg
# @env OVERWRITE_CONFIG_FILES indicates if target directory should be overwritten if it exists
# @env PRETTY_ROOT_DIR used to make paths relative to this directory to reduce length of messages
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
    PRETTY_ROOT_DIR="${embedDir%/*}" \
    Install::structure "${configDir}/${subDir}" "${targetDir}"
}
