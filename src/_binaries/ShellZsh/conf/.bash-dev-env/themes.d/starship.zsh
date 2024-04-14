#!/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################
if ! typeset -f zinit > /dev/null; then
  return 0
fi

if [[ "${ZSH_PREFERRED_THEME:-${ZSH_DEFAULT_THEME}}" != "starship/starship" ]]; then
  return 0
fi

# Load starship theme
# line 1: `starship` binary as command, from github release
# line 2: starship setup at clone(create init.zsh, completion)
# line 3: pull behavior same as clone, source init.zsh
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship
typeset -g ZSH_THEME="starship/starship"
