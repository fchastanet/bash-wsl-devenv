#!/bin/zsh

# do not set git aliases
save_aliases=$(alias -L)
zinit wait lucid for \
  OMZL::git.zsh \
  atload"unalias -m '*'; eval ${save_aliases}; unset save_aliases" \
  OMZP::git
