#!/usr/bin/env zsh

if typeset -f zinit >/dev/null; then
  mkdir -p "${ZSH_CACHE_DIR}/completions"
  touch "${ZSH_CACHE_DIR}/completions/_docker"
  zinit wait lucid depth=1 load light-mode for \
    make'alias alias=' as"completion" OMZP::docker \
    make'alias alias=' as"completion" OMZP::docker-compose
fi
