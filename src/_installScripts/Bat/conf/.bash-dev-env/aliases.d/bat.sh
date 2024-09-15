#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# Allows to do $ help cp or $ help git commit.
alias batHelp='bat --plain --language=help'
h() {
  "$@" --help 2>&1 | batHelp
}
