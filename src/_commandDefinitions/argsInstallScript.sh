#!/usr/bin/env bash

# shellcheck disable=SC2034
declare commandFunctionName="installScriptCommand"

isInterfaceMandatoryFunctionImplemented() {
  isFunctionImplemented helpDescription || return 1
  isFunctionImplemented helpLongDescription || return 1
  isFunctionImplemented scriptName || return 1
  isFunctionImplemented dependencies || return 1
  isFunctionImplemented listVariables || return 1
  isFunctionImplemented fortunes || return 1
  isFunctionImplemented helpVariables || return 1
  isFunctionImplemented defaultVariables || return 1
  isFunctionImplemented checkVariables || return 1
  isFunctionImplemented breakOnConfigFailure || return 1
  isFunctionImplemented breakOnTestFailure || return 1
  isFunctionImplemented install || return 1
  isFunctionImplemented testInstall || return 1
  isFunctionImplemented configure || return 1
  isFunctionImplemented testConfigure || return 1
}

scriptName() {
  echo "{{ .Data.binData.commands.default.commandName }}"
}

beforeParseCallback() {
  defaultBeforeParseCallback
  isInterfaceMandatoryFunctionImplemented
}

commandHelpFunction() {
  echo "Available commands:"
  echo ""
}

listOrNone() {
  local string="$1"
  if [[ -z "${string:-}" ]]; then
    echo -e "${__HELP_EXAMPLE}None${__HELP_NORMAL}" | sed 's/^/    /'
  else
    echo -ne "${__HELP_OPTION_COLOR}"
    echo -e "${string}" | sed 's/^/    - /'
    echo -ne "${__HELP_NORMAL}"
  fi
}

helpDescriptionFunction() {
  helpDescription
  echo
}

helpLongDescription() {
  helpDescription
}

helpLongDescriptionFunction() {
  helpLongDescription | sed 's/^/  /'
  echo
  echo -e "  ${__HELP_TITLE}List of needed variables:${__HELP_NORMAL}"
  listOrNone "$(listVariables)"
  echo
  local variables
  variables="$(helpVariables)"
  if [[ -n "${variables}" ]]; then
    echo -e "${variables}" | sed 's/^/    /'
    echo
  fi
  echo -e "  ${__HELP_TITLE}List of dependencies:${__HELP_NORMAL}"
  listOrNone "$(dependencies)"
}

isFunctionImplemented() {
  local functionName="$1"
  if ! Assert::functionExists "${functionName}"; then
    Log::displayError "Function ${functionName} is not implemented"
    return 1
  fi
}

isInstallImplemented() {
  ! InstallScripts::scriptFunctionEmpty install
}

isTestInstallImplemented() {
  ! InstallScripts::scriptFunctionEmpty testInstall
}

isConfigureImplemented() {
  ! InstallScripts::scriptFunctionEmpty configure
}

isTestConfigureImplemented() {
  ! InstallScripts::scriptFunctionEmpty testConfigure
}

fullScriptName() {
  File::relativeToDir "${REAL_SCRIPT_FILE}" "${BASH_DEV_ENV_ROOT_DIR}"
}

argsInstallScriptCommandCallback() {
  if [[ -n "${command}" ]]; then
    if Array::contains "${command}" install testInstall configure testConfigure; then
      afterParseCallback
    fi
    "${command}"; exit $?
  fi
}
