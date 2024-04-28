#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

[[ :${PATH}: == *":${HOME}/.local/bin:"* ]] || PATH="${HOME}/.local/bin:${PATH}"
export PATH

# load this virtualenv
if [[ -f "${HOME}/.virtualenvs/python3/bin/activate" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.virtualenvs/python3/bin/activate"
fi
