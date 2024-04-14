#!/bin/bash

alias a='fasd -a'
alias s='fasd -si'
alias sd='fasd -sid'
alias sf='fasd -sif'
alias d='fasd -d'
alias f='fasd -f'

# function to execute built-in cd
fasd_cd() {
  if (( $# <= 1 )); then
    fasd "$@"
  else
    local _fasd_ret
    _fasd_ret="$(fasd -e 'printf %s' "$@")"
    if [[ -z "${_fasd_ret}" ]]; then
      return
    fi
    if [[ -d "${_fasd_ret}" ]]; then
      cd "${_fasd_ret}" || printf '%s\n' "${_fasd_ret}"
    fi
  fi
}
alias z='fasd_cd -d'
alias zz='fasd_cd -d -i'
