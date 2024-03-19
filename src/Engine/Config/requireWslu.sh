#!/bin/bash

# @description install apt wslu if necessary providing wslvar, wslpath
Engine::Config::requireWslu() {
  if ! command -v wslvar &>/dev/null; then
    Log::displayInfo "Installing pre-requisite Wslu : wslvar, wslpath, ... commands"
    Linux::Apt::update
    Linux::Apt::install --no-install-recommends wslu
  fi
}
