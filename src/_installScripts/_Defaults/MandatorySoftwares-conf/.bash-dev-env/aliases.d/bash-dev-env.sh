#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# This installer aliases
installAndConfigure() {
  (
    cd "${HOME}/fchastanet/bash-dev-env" || return 1
    ./install "$@"
  )
}
alias installAndConfigure='installAndConfigure'
