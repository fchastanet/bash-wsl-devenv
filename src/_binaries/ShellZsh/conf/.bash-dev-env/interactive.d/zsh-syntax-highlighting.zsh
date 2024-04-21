#!/usr/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if typeset -f zinit >/dev/null; then
  zinit lucid depth=1 load light-mode for \
    wait atinit"zicompinit; zicdreplay" zdharma-continuum/fast-syntax-highlighting \
    wait OMZP::colored-man-pages
fi
