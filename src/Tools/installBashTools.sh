#!/usr/bin/env bash

# @description install bash-tools
Tools::installBashTools() {
  # shellcheck disable=SC2317
  function installBashTools() {
    (
      cd "${HOME}/fchastanet/bash-tools" || return 1
      ./install
    )
  }
  Git::cloneOrPullIfNoChanges \
    "${HOME}/fchastanet/bash-tools" \
    "https://github.com/fchastanet/bash-tools.git" \
    installBashTools
}
