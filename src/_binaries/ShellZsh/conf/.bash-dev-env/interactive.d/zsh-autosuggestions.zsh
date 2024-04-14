#!/usr/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

__zinit_plugin_loaded_callback() {
  ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/forward-char}")
  ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=forward-char
}
zinit wait lucid depth=1  \
  atload='__zinit_plugin_loaded_callback' \
  for \
    zsh-users/zsh-autosuggestions
typeset -g ZSH_AUTOSUGGEST_USE_ASYNC=true
