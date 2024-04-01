#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# Set up fzf key bindings and fuzzy completion
if [[ "${SHELL}" = "/bin/bash" ]]; then
  eval "$(fzf --bash)"
elif [[ "${SHELL}" = "/bin/zsh" ]]; then
  eval "$(fzf --zsh)"
elif [[ "${SHELL}" = "/bin/fish" ]]; then
  fzf --fish | source
fi
