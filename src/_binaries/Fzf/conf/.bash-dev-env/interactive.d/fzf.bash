#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# Set up fzf key bindings and fuzzy completion
if [[ ! "${PATH}" == *${HOME}/.fzf/bin* ]]; then
  PATH="${PATH}:${HOME}/.fzf/bin"
fi

if [[ -f "${HOME}/.fzf.bash" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.fzf.bash"
fi
