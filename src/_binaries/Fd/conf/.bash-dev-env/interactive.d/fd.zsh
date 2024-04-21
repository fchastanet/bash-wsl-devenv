#!/usr/bin/env zsh

if typeset -f zinit >/dev/null; then
  zinit wait lucid depth=1 load light-mode for \
    as"completion" OMZP::fd/_fd
fi
