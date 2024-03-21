#!/bin/bash

Conf::addLinesToShellEntrypoint() {
  if [[ "${SHELL}" = "/usr/bin/bash" ]]; then
    Log::displayInfo "Please add these lines at the end of your ~/.bashrc"
  elif [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
    Log::displayInfo "Please add these lines at the end of your ~/.zshrc"
  else
    Log::displayInfo "Please add these lines at the end of your shell entrypoint (${SHELL})"
  fi
}
