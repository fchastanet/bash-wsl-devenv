#!/bin/bash

# fasd
if command -v fasd &>/dev/null; then
  fasd_cache="${HOME}/.fasd-init-bash"
  if [[ "$(command -v fasd)" -nt "${fasd_cache}" || ! -s "${fasd_cache}" ]]; then
    fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >|"${fasd_cache}"
  fi
  # shellcheck source=/dev/null
  source "${fasd_cache}"
  unset fasd_cache
fi
