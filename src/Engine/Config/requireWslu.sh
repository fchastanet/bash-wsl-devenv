#!/bin/bash

# @description install apt wslu if necessary providing wslvar, wslpath
Engine::Config::requireWslu() {
  if [[ "${LOAD_WSLU:-1}" = "0" ]]; then
    return 0
  fi
  if ! command -v wslvar &>/dev/null; then
    Log::displayInfo "Installing pre-requisite Wslu : wslvar, wslpath, ... commands"
    Linux::Apt::installIfNecessary --no-install-recommends wslu

    # @see https://github.com/microsoft/WSL/issues/8843#issuecomment-1792256894
    Log::displayInfo "Fix wsl interoperability due to wsl bug"
    if [[ ! -f /usr/lib/binfmt.d/WSLInterop.conf &&
      ! -f /etc/systemd/system/wsl-binfmt.service &&
      -f /run/systemd/generator.early/wsl-binfmt.service ]]; then
      sudo sh -c 'echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf'
      sudo ln -s /run/systemd/generator.early/wsl-binfmt.service /etc/systemd/system/wsl-binfmt.service
    fi
  fi
}
