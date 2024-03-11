%
declare commandFunctionName="installScriptCommand"
helpDescriptionCallback() { :; }
help=helpDescriptionCallback
helpLongDescriptionCallback() { :; }
longDescription=helpLongDescriptionCallback
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.default.options.tpl)"

%
Options::generateCommand "${options[@]}"
%

defaultFacadeAction() {
  <% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
}

# we need non root user to be sure that all variables will be correctly deduced
Assert::expectNonRootUser

stringOrNone() {
  local string="$1"
  echo -e "${string:-${__HELP_EXAMPLE}None${__HELP_NORMAL}}"
}

helpDescriptionCallback() {
  installScript_helpDescription
  echo
}

helpLongDescriptionCallback() {
  installScript_helpDescription
  echo

  echo -e "${__HELP_TITLE}List of needed variables:${__HELP_NORMAL}"
  stringOrNone "$(installScript_helpVariables)"

  echo -e "${__HELP_TITLE}List of dependencies:${__HELP_NORMAL}"
  stringOrNone "$(installScript_dependencies)"
}

rm -f "${CONFIG_LOGS_DIR:-#}/${SCRIPT}-.*" || true

# shellcheck disable=SC2317
computeStatsTrap() {
  local status="$?"
  local step="$1"
  local logFile="$2"
  local statFile="$3"
  local END
  END="$(date +%s)"
  Stats::computeFromLog "${logFile}" "${status}" "$((END - START))" >"${statFile}"
  Stats::statusLine "${statFile}" "${step}"
  return "${status}"
}

onInterrupt() {
  Log::displayError "${SCRIPT} aborted"
  exit 1
}
trap 'onInterrupt' INT TERM ABRT

declare installStatus="0"
if [[ "${SKIP_INSTALL}" = "0" ]]; then
  Log::headLine "INSTALL - Installing ${SCRIPT}"
  installLogFile="${CONFIG_LOGS_DIR}/${SCRIPT}-install.log"
  installStatsFile="${CONFIG_LOGS_DIR}/${SCRIPT}-install.stat"

  (
    declare START
    START="$(date +%s)"
    trap 'computeStatsTrap "Installation ${SCRIPT}" "${installLogFile}" "${installStatsFile}"' EXIT INT TERM ABRT

    "installScripts_${SCRIPT}_install" 2>&1 | tee "${installLogFile}"
  ) || installStatus="$?" || true
  if [[ "${installStatus}" != "0" ]]; then
    # break at first install error
    exit "${installStatus}"
  fi
fi

declare configStatus="0"
if [[ "${SKIP_CONFIGURE}" = "0" && "${installStatus}" = "0" ]]; then
  Log::headLine "CONFIG  - Configuring ${SCRIPT}"
  configLogFile="${CONFIG_LOGS_DIR}/${SCRIPT}-config.log"
  configStatsFile="${CONFIG_LOGS_DIR}/${SCRIPT}-config.stat"
  (
    declare START
    START="$(date +%s)"
    trap 'computeStatsTrap "Configuration ${SCRIPT}" "${configLogFile}" "${configStatsFile}"' EXIT INT TERM ABRT

    "installScripts_${SCRIPT}_configure" 2>&1 | tee "${configLogFile}"
  ) || configStatus="$?" || true

  if [[ "${configStatus}" != "0" ]] && "installScripts_${SCRIPT}_breakOnConfigFailure"; then
    # break if config script error
    exit "${configStatus}"
  fi
fi

declare testStatus="0"
if [[ "${SKIP_TEST}" = "0" && "${installStatus}" = "0" && "${configStatus}" = "0" ]]; then
  Log::headLine "TEST    - Testing ${SCRIPT}"
  testLogFile="${CONFIG_LOGS_DIR}/${SCRIPT}-test.log"
  testStatsFile="${CONFIG_LOGS_DIR}/${SCRIPT}-test.stat"
  (
    declare START
    START="$(date +%s)"
    trap 'computeStatsTrap "Test ${SCRIPT}" "${testLogFile}" "${testStatsFile}"' EXIT INT TERM ABRT

    "installScripts_${SCRIPT}_test" 2>&1 | tee "${testLogFile}"
  ) || testStatus="$?" || true
  if [[ "${testStatus}" != "0" ]] && "installScripts_${SCRIPT}_breakOnTestFailure"; then
    # break if test script error
    exit "${testStatus}"
  fi
fi
