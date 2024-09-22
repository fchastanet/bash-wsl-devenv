#!/usr/bin/env bash

helpDescription() {
  echo "$(scriptName) - A performant, and portable jq wrapper"
}

helpLongDescription() {
  helpDescription
  echo "to facilitate the consumption and output"
  echo "of formats other than JSON."
  echo "Using jq filters to transform the data."
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}oq${__RESET_COLOR} is a ${__HELP_EXAMPLE}jq${__RESET_COLOR} wrapper but able to parse other formats than json."
  echo -e "${__HELP_EXAMPLE}<https://blacksmoke16.github.io/oq/>${__RESET_COLOR}"
  echo "%"
}

oqParseVersion() {
  grep "oq" | Version::parse
}

oqVersion() {
  "$1" --version 2>&1 | oqParseVersion
}

install() {
  SUDO=sudo SOFT_VERSION_CALLBACK=oqVersion Github::upgradeRelease \
    "/usr/local/bin/oq" \
    "https://github.com/Blacksmoke16/oq/releases/download/v@latestVersion@/oq-v@latestVersion@-Linux-x86_64"
}

testInstall() {
  Version::checkMinimal "oq" --version "1.3.4" oqParseVersion || return 1
}
