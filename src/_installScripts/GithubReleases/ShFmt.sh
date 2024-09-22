#!/usr/bin/env bash

helpDescription() {
  echo "A shell parser, formatter, and interpreter. Supports POSIX Shell, Bash, and mksh."
}

dependencies() {
  echo "installScripts/Go"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- the following linter is available: ${__HELP_EXAMPLE}shfmt${__RESET_COLOR}"
  echo "%"
}

install() {
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/shfmt \
    "https://github.com/mvdan/sh/releases/download/v@latestVersion@/shfmt_v@latestVersion@_linux_amd64"
}

testInstall() {
  Version::checkMinimal "shfmt" --version "3.9.0" || return 1
}
