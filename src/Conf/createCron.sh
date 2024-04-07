#!/bin/bash

# @description create cron file based on a template
# @arg $1 targetFile:String
# @arg $2 logFile:String log file that will be written by this cron
# @arg $@ cmd:String[] the command that should be executed by this cron
# @env MNT_C path to c drive mount
# @env BASH_DEV_ENV_ROOT_DIR
# @env SUDO String allows to use custom sudo prefix command
Conf::createCron() {
  local targetFile="$1"
  local logFile="$2"
  shift 2 || true
  local -a cmd=("$@")

  (
    echo '#!/bin/bash'
    echo '###############################################################################'
    echo '# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE'
    echo '###############################################################################'
    echo
    # shellcheck disable=SC2016
    echo -n 'export PATH=${PATH}'
    echo -n ":${MNT_C}/Windows"
    echo -n ":${MNT_C}/Windows/system32"
    echo -n ":${MNT_C}/Windows/System32/Wbem"
    echo -n ":${MNT_C}/Windows/System32/WindowsPowerShell/v1.0"
    echo
    echo
    # Upgrade every 7 days at 21pm
    echo "cd '${BASH_DEV_ENV_ROOT_DIR}'"
    echo "${cmd[*]} &>'${BASH_DEV_ENV_ROOT_DIR}/logs/${logFile}'"
    echo
  ) | ${SUDO:-} tee "${targetFile}" >/dev/null
  ${SUDO:-} chmod +x "${targetFile}"
}
