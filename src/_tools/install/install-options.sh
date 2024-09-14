#!/usr/bin/env bash

generateSoftwaresList() {
  local description
  local list
  list="$(
    Conf::list "${INSTALL_SCRIPTS_ROOT_DIR}" "" "" "-type f" "" |
      grep -v -E '^(_.*|MandatorySoftwares)$' || true
  )"
  local -i maxLineLength
  maxLineLength="$(wc -L <<<"${list}")"
  while read -r soft; do
    echo -en "  - ${__HELP_TITLE_COLOR}${soft} ${__HELP_EXAMPLE}"
    printf -- '_%.0s' $(seq "$((maxLineLength - ${#soft} + 1))")
    description="$(SKIP_REQUIRES=1 "${INSTALL_SCRIPTS_ROOT_DIR}/${soft}" helpDescription 2>/dev/null)"
    if [[ -z "${description}" ]]; then
      echo " <No description available>"
    else
      sed '2,$s/^/      /' <<<" ${description}"
    fi
    echo -en "${__RESET_COLOR}"
  done <<<"${list}"
}

declare -i help_cache_max_duration=86400
helpLongDescriptionFunction() {
  LOAD_SSH_KEY=0 afterParseCallback
  local softwaresListHelpTempFile
  softwaresListHelpTempFile="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}/bash_dev_env_install_software_arg_help_cache"

  if [[ ! -f "${softwaresListHelpTempFile}" ]] ||
    (($(File::elapsedTimeSinceLastModification "${softwaresListHelpTempFile}") > help_cache_max_duration))
  then
    echo >&2 -n "Generating softwares list cache ..."
    generateSoftwaresList > "${softwaresListHelpTempFile}" || rm -f "${softwaresListHelpTempFile}"
    echo >&2 -e "\033[2K" # erase line (Generating softwares list cache ...)
  fi

  echo "  Install or update softwares (kube, aws, composer, node, ...)."
  echo "  Configure Home environment (git config, kube, motd, ssh, dns, ...)."
  echo "  And check configurations."
  echo
  echo -e "  ${__HELP_TITLE_COLOR}Available softwares:${__RESET_COLOR}"
  cat "${softwaresListHelpTempFile}"
  echo
  profilesHelpList
}
