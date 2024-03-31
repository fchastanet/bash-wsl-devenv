#!/bin/bash

# Set up fzf key bindings and fuzzy completion
if [[ "${SHELL}" = "/bin/bash" ]]; then
  eval "$(fzf --bash)"
elif [[ "${SHELL}" = "/bin/zsh" ]]; then
  eval "$(fzf --zsh)"
elif [[ "${SHELL}" = "/bin/fish" ]]; then
  fzf --fish | source
fi
