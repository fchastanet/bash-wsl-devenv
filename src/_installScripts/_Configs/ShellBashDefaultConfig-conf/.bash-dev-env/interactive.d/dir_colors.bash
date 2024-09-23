#!/bin/bash

# load dir colors
if [[ -f "${HOME}/.dir_colors" ]]; then
  eval "$(dircolors "${HOME}/.dir_colors")"
fi
