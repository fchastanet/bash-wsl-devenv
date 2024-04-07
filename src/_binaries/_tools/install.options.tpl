%
declare versionNumber="1.0"
declare copyrightBeginYear="2024"
declare commandFunctionName="installCommand"
declare help="Install or update softwares"
declare longDescription="""
Install or update softwares (kube, aws, composer, node, ...),
configure Home environnement (git config, kube, motd, ssh, dns, ...) and check configuration

List of softwares available:
@@@SOFTWARES_LIST_HELP@@@
"""
%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.profile.options.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.skip.options.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.prepareExport.option.tpl)"

generateSoftwaresList() {
  while read -r soft; do
    echo -en "  - ${__HELP_TITLE_COLOR}${soft}: ${__HELP_EXAMPLE}"
    SKIP_REQUIRES=1 "${INSTALL_SCRIPTS_DIR}/${soft}" helpDescription 2>/dev/null || echo
    echo -en "${__RESET_COLOR}"
  done < <(
    Conf::list "${INSTALL_SCRIPTS_DIR}" "" "" "-type f" "" |
      grep -v -E '^(_.*|MandatorySoftwares)$' || true
  )
}

declare -i help_cache_max_duration=86400
optionHelpCallback() {
  local softwaresListHelpTempFile
  softwaresListHelpTempFile="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}/bash_dev_env_install_software_arg_help_cache"

  if [[ ! -f "${softwaresListHelpTempFile}" ]] ||
    (($(File::elapsedTimeSinceLastModification "${softwaresListHelpTempFile}") > help_cache_max_duration))
  then
    echo >&2 -n "Generating softwares list cache ..."
    generateSoftwaresList > "${softwaresListHelpTempFile}"
    echo >&2 -e "\033[2K"
  fi

  <% ${commandFunctionName} %> help |
    sed -E \
      -e "/@@@SOFTWARES_LIST_HELP@@@/r ${softwaresListHelpTempFile}" \
      -e "/@@@SOFTWARES_LIST_HELP@@@/d"
  exit 0
}

%
Options::generateCommand "${options[@]}"
%

<% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
