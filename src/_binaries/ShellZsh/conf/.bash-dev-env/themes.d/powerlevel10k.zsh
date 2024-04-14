#!/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################
if ! typeset -f zinit > /dev/null ||
  [[ "${ZSH_PREFERRED_THEME:-${ZSH_DEFAULT_THEME}}" != "powerlevel10k/powerlevel10k" ]]
then
  return 0
fi

if [[
  -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# zinit for \
#     atload"source ${HOME}/.p10k.zsh; _p9k_precmd" \
#     nocd \
#     wait'!' \
#     lucid \
#     light-mode \
#     depth=1 \
#     silent \
#   romkatv/powerlevel10k \
#   OMZL::history.zsh \
#   blockf OMZL::completion.zsh
# zinit light romkatv/powerlevel10k

# This would turbo-load p10k, but it's not compatible with p10k instant mode
# zinit wait='!' depth=1 lucid nocd \
#     atload='_p9k_precmd' for \
#         romkatv/powerlevel10k

# Using normal load works
zinit depth=1 lucid nocd \
  atload"source ${HOME}/.p10k.zsh; _p9k_precmd" \
  for \
    romkatv/powerlevel10k \
    OMZL::history.zsh \
    blockf OMZL::completion.zsh

typeset -g ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
typeset -g ZSH_THEME="powerlevel10k/powerlevel10k"

if (( ! ${+functions[p10k]} ))
then
  p10k finalize
fi
