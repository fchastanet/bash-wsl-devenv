#!/usr/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if typeset -f zinit >/dev/null; then
  zinit lucid depth=1 load light-mode for \
    blockf atpull'zinit creinstall -q .' zsh-users/zsh-completions
fi
