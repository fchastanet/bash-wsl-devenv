%
# shellcheck source=/dev/null
source <(
  profileHelp() { :; }
  Options::generateOption \
    --help profileHelp \
    --help-value-name profile \
    --variable-type "String" \
    --alt "--profile" \
    --alt "-p" \
    --callback validateProfile \
    --variable-name "PROFILE" \
    --function-name optionProfileFunction

  softwareArgHelp() { :; }
  Options::generateArg \
    --variable-name "CONFIG_LIST" \
    --min 0 \
    --max -1 \
    --name "softwares" \
    --help softwareArgHelp \
    --function-name softwaresArgFunction
)
options+=(
  optionProfileFunction
  softwaresArgFunction
  --callback commandCallback
)
%

profileHelp() {
  echo "Profile name to use that contains all the softwares to install"
  echo "List of profiles available:"
  echo
  (
    Conf::list "${BASH_DEV_ENV_ROOT_DIR}/profiles" "profile." ".sh" "-type f" "   - "
    local dir
    for dir in "${BASH_DEV_ENV_ROOT_DIR}/srcAlt/"*; do
      if [[ -d "${dir}/profiles" ]]; then
        Conf::list "${dir}/profiles" "profile." ".sh" "-type f" "   - "
      fi
    done
  ) | sort | uniq
}

softwareArgHelp() {
  echo "List of softwares to install (--profile option cannot be used in this case)"
  echo "See below for complete list of softwares available"
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
