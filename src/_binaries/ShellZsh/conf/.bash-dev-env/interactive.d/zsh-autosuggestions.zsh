#!/usr/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if typeset -f zinit >/dev/null; then
  __zinit_plugin_loaded_callback() {
    _zsh_autosuggest_start
    ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=("${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]/forward-char}")
    ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=forward-char
  }
  zinit lucid depth=1 load light-mode for \
    atload='__zinit_plugin_loaded_callback' zsh-users/zsh-autosuggestions

  typeset -g ZSH_AUTOSUGGEST_USE_ASYNC=true
fi
