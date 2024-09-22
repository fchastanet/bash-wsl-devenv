#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# fasd
if command -v fasd &>/dev/null; then
  fasd_cache="${HOME}/.fasd-init-bash"
  if [[ "$(command -v fasd)" -nt "${fasd_cache}" || ! -s "${fasd_cache}" ]]; then
    fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >|"${fasd_cache}"
  fi
  # shellcheck source=/dev/null
  source "${fasd_cache}"
  unset fasd_cache

  _fasd_prompt_func() {
    # shellcheck disable=SC2046
    eval "fasd --proc $(fasd --sanitize $(history 1 | sed "s/^[ ]*[0-9]*[ ]*//"))" &>/dev/null
  }

  # add bash hook
  case "${PROMPT_COMMAND}" in
    *_fasd_prompt_func*) ;;
    *) PROMPT_COMMAND="_fasd_prompt_func;${PROMPT_COMMAND}" ;;
  esac
fi
