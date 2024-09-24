#!/usr/bin/env bash

# we need non root user to be sure that all variables will be correctly deduced
Linux::requireExecutedAsUser

generateFortunes() {
  echo >/etc/fortune-help-commands
  (
    for configName in "${CONFIG_LIST[@]}"; do
      if [[ -z "${configName}" ]]; then
        continue
      fi
      (
        local fortunes
        fortunes="$("${BASH_DEV_ENV_ROOT_DIR}/${configName}" fortunes | Filters::trimEmptyLines)"
        if [[ -n "${fortunes}" ]]; then
          echo -e "${fortunes}"
          Log::displayInfo "${configName} - $(grep -cE '^%$' <<<"${fortunes}") fortunes generated"
        else
          Log::displayInfo "${configName} - no fortune generated"
        fi
      ) >>/etc/fortune-help-commands || {
        Log::displayWarning "Script ${configName} - fortunes failed to be loaded"
      }
    done
  ) 2>&1 | tee >(sed -r 's/\x1b\[[0-9;]*m//g' >>"${LOGS_DIR}/automatic-fortune") || return 1
  Log::displayInfo "$(grep -cE '^%$' /etc/fortune-help-commands) fortunes generated"
}

generateFortunesDat() {
  # generate dat file
  sudo strfile -c % /etc/fortune-help-commands /etc/fortune-help-commands.dat
}

LOGS_DIR="${LOGS_DIR:-${PERSISTENT_TMPDIR}}"

Profiles::checkScriptsExistence "${BASH_DEV_ENV_ROOT_DIR}" "" "${CONFIG_LIST[@]}"
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
