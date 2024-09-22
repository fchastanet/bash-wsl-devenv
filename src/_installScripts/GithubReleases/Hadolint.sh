#!/usr/bin/env bash

helpDescription() {
  echo "Dockerfile linter, validate inline bash, written in Haskell"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- the following linter is available: ${__HELP_EXAMPLE}hadolint${__RESET_COLOR}"
  echo "%"
}

install() {
  SUDO=sudo Github::upgradeRelease \
    "/usr/local/bin/hadolint" \
    "https://github.com/hadolint/hadolint/releases/download/v@latestVersion@/hadolint-Linux-x86_64"
}

testInstall() {
  Version::checkMinimal "hadolint" --version "2.12.0" || return 1
}
