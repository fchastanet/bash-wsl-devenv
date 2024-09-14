#!/bin/bash

softwareArgHelpFunction() {
  echo "    List of softwares to install (--profile option cannot be used in this case)"
  echo "    See below for complete list of softwares available"
}

profileHelpFunction() {
  echo "    Profile name to use that contains all the softwares to install"
}

profilesHelpList() {
  echo -e "  ${__HELP_TITLE_COLOR}Available profiles:${__RESET_COLOR}"
  (
    Conf::list "${BASH_DEV_ENV_ROOT_DIR}/profiles" "profile." ".sh" "-type f" "    - "
    local dir
    for dir in "${BASH_DEV_ENV_ROOT_DIR}/srcAlt/"*; do
      if [[ -d "${dir}/profiles" ]]; then
        Conf::list "${dir}/profiles" "profile." ".sh" "-type f" "    - "
      fi
    done
  ) | sort | uniq
}

validateProfile() {
  local profileName="$2"
  if ! Profiles::getProfilePath "${profileName}" &>/dev/null; then
    Log::fatal "Profile file profile.${profileName}.sh doesn't exist in any profiles directory"
  fi
}

commandCallback() {
  if ((${#CONFIG_LIST} > 0)); then
    if [[ -n "${PROFILE}" ]]; then
      Log::fatal "You cannot combine profile and softwares"
    fi
    # check if each Softwares exists
    local software
    for software in "${CONFIG_LIST[@]}"; do
      if [[ ! -f "${BASH_DEV_ENV_ROOT_DIR}/${software}" ]]; then
        Log::fatal "Software ${software} configuration does not exists"
      fi
    done
  elif [[ -z "${PROFILE}" ]]; then
    Log::fatal "You must specify either a list of softwares, either a profile name"
  else
    # get profile path
    local profilePath
    profilePath="$(Profiles::getProfilePath "${PROFILE}")" # should succeed as it was tested by option
    # load selected profile
    Profiles::loadProfile "${profilePath}"
  fi
  if [[ "${SKIP_DEPENDENCIES:-0}" = "0" ]]; then
    CONFIG_LIST=("${CONFIG_LIST[@]}")

    declare rootDependency="your software selection"
    if [[ -n "${PROFILE}" ]]; then
      rootDependency="profile ${PROFILE}"
    fi
    # deduce dependencies
    declare -ag allDepsResult=()
    # shellcheck disable=SC2034
    declare -Ag allDepsResultSeen=()

    Profiles::allDepsRecursive \
      "${INSTALL_SCRIPTS_ROOT_DIR}" "${rootDependency}" "${CONFIG_LIST[@]}"

    CONFIG_LIST=("${allDepsResult[@]}")
  fi
  if ((${#CONFIG_LIST} == 0)); then
    Log::fatal "Softwares list is empty"
  fi
}

export CONFIG_LIST
export PROFILE
