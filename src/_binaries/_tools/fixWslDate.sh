#!/bin/bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/bin/fixWslDate
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=
# VAR_LOAD_REQUIRES=0
# VAR_LOAD_CONFIG=0
# FACADE

Linux::requireExecutedAsRoot
getDate() {
  wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 |
    sed -n 's/^ *Date: *//p'
}
date -s "$(getDate)" &>/dev/null
