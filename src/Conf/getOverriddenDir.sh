#!/bin/bash

# @description generate temp directory where default
# and overridden directories have been merged
#   - if overridden dir exists, create a new temp folder
#     - copy all files from default folder
#     - overwrite with files from overridden folder
#     - (Later) delete files listed in .remove$$ file
#     - return the path of this temp folder
#   - else just return the default folder path
# Then it is easier to pick overridden or default files/folders
#
# @arg $1 defaultDir:String usually the embed directory
# @arg $2 overriddenDirPath:String the path to the directory
#   that could be overridden
# @exitcode 1 if default dir does not exist
# @exitcode 2 if error during copy
Conf::getOverriddenDir() {
  local defaultDir="$1"
  local overriddenDirPath="$2"

  if [[ ! -d "${defaultDir}" ]]; then
    Log::displayError "Directory ${defaultDir} does not exists"
    return 1
  fi
  if [[ ! -d "${overriddenDirPath}" || -z "$(ls -A "${overriddenDirPath}")" ]]; then
    Log::displayInfo "Conf::getOverriddenDir - directory ${overriddenDirPath} does not exist, keep default one ${defaultDir}"
    echo "${defaultDir}"
    return 0
  fi
  local tempDir
  tempDir="$(mktemp -d)"
  (
    shopt -s dotglob
    cp -R "${defaultDir}/." "${tempDir}"
    cp -R "${overriddenDirPath}/." "${tempDir}"
  ) || return 2
  echo "${tempDir}"
}
