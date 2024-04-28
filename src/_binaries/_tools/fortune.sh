#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/bin/fortune
# FACADE
# BASH_DEV_ENV_ROOT_DIR_RELATIVE_TO_BIN_DIR=..

# variables
CONFIG_LIST=()
# shellcheck disable=SC2034
PROFILE=

# trap errors
err_report() {
  echo "$0 - Fortune failure - Error on line $1"
  exit 1
}
trap 'err_report $LINENO' ERR

.INCLUDE "$(dynamicTemplateDir _binaries/_tools/fortune.options.tpl)"

generateFortunes() {
  echo >/etc/fortune-help-commands
  if [[ "${SHOW_FORTUNES}" = "1" ]]; then
    (
      for configName in "${CONFIG_LIST[@]}"; do
        (
          local fortunes
          fortunes="$("${INSTALL_SCRIPTS_ROOT_DIR}/${configName}" fortunes | Filters::trimEmptyLines)"
          if [[ -n "${fortunes}" ]]; then
            echo "${fortunes}"
          fi
        ) >>/etc/fortune-help-commands || {
          Log::displayWarning "Script ${configName} - fortunes failed to be loaded"
        }
      done
    ) 2>&1 | tee >(sed -r 's/\x1b\[[0-9;]*m//g' >>"${LOGS_DIR}/automatic-fortune") || return 1
    Log::displayInfo "$(grep -cE '^%$' /etc/fortune-help-commands) fortunes generated"
  fi
}

generateFortunesDat() {
  # generate dat file
  sudo strfile -c % /etc/fortune-help-commands /etc/fortune-help-commands.dat
}

# we need non root user to be sure that all variables will be correctly deduced
# @require Linux::requireExecutedAsUser
run() {
  LOGS_DIR="${LOGS_DIR:-${PERSISTENT_TMPDIR}}"

  Profiles::checkScriptsExistence "${INSTALL_SCRIPTS_DIR}" "" "${CONFIG_LIST[@]}"
  Log::displayInfo "Will Install ${CONFIG_LIST[*]}"

  # Start install process
  Log::rotate "${LOGS_DIR}/automatic-fortune"

  # indicate to install scripts to avoid loading wsl
  export WSL_GARBAGE_COLLECT=0
  export WSL_INIT=0
  export CHECK_ENV=0
  # force interactive mode, otherwise Assert::tty return false
  export INTERACTIVE=1

  generateFortunes
  generateFortunesDat
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run "$@" &>/dev/null
else
  run "$@"
fi
