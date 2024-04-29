#!/usr/bin/env bash

# @description load profile file based on profileFile argument
# The profile file is profileDir/profile.profile.sh
# This file should define the variable CONFIG_LIST with array type
# @arg $1 profileFile:String full profile path
# @exitcode 1 if argument is not provided
# @exitcode 2 if profile not found
# @exitcode 3 if profile found but CONFIG_LIST variable unset
# @exitcode 4 if profile found but CONFIG_LIST variable empty
# @exitcode 5 if error occurs during profile loading
# @stderr diagnostics information is displayed
# @see Profiles::allDepsRecursive in order to load all the dependencies recursively based on this list
# @set CONFIG_LIST
Profiles::loadProfile() {
  local profileFile="$1"

  if [[ -z "${profileFile}" ]]; then
    Log::displayError "This method needs exactly 1 parameter"
    return 1
  fi

  # load the profile
  Log::displayInfo "Loading profile '${profileFile}'"
  if [[ ! -f "${profileFile}" ]]; then
    Log::displayError "profile ${profileFile} not found"
    return 2
  fi

  # shellcheck source=src/Profiles/testsData/profile.test1.sh
  source "${profileFile}" || return 5

  if [[ ! -v CONFIG_LIST ]]; then
    Log::displayError "Profile ${profileFile} missing variable CONFIG_LIST"
    return 3
  fi
  if [[ ${#CONFIG_LIST[@]} -eq 0 ]]; then
    Log::displayError "Profile ${profileFile} variable CONFIG_LIST cannot be empty"
    return 4
  fi

  # remove duplicates from profile preserving order
  mapfile -t CONFIG_LIST < <(
    IFS=$'\n' printf '%s\n' "${CONFIG_LIST[@]}" | Filters::uniqUnsorted
  )
}
