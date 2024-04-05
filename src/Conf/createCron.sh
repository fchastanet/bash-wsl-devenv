#!/bin/bash

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
    echo ; echo
    # Upgrade every 7 days at 21pm
    echo "cd '${BASH_DEV_ENV_ROOT_DIR}'"
    echo "${cmd[*]} &>'${BASH_DEV_ENV_ROOT_DIR}/logs/${logFile}'"
    echo
  ) | ${SUDO:-} tee "${targetFile}" >/dev/null
  ${SUDO:-} chmod +x "${targetFile}"
}