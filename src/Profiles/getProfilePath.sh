#!/usr/bin/env bash

# @description deduce profile path from given profile name
# if 2 profiles are named identically the first existing profile
# will be used beginning with srcAlt profiles
# @arg $1 profileName:String
# @stdout the path of the profile, no output if profile not found
# @exitCode 1 if profile not found
Profiles::getProfilePath() {
  local profileName="$1"
  local dir
  for dir in "${BASH_DEV_ENV_ROOT_DIR}/srcAlt/"*; do
    profilePath="${dir}/profiles/profile.${profileName}.sh"
    if [[ -f "${profilePath}" ]]; then
      echo "${profilePath}"
      return 0
    fi
  done
  local profilePath="${BASH_DEV_ENV_ROOT_DIR}/profiles/profile.${profileName}.sh"
  if [[ -f "${profilePath}" ]]; then
    echo "${profilePath}"
    return 0
  fi

  return 1
}
