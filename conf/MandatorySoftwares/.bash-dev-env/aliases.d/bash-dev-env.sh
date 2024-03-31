#!/bin/bash

# This installer aliases
installAndConfigure() {
  (
    cd "${HOME}/fchastanet/bash-dev-env" || return 1
    ./install "$@"
  )
}
alias installAndConfigure='installAndConfigure'
