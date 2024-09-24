#!/usr/bin/env bash

helpDescription() {
  echo "$(scriptName) - text-mode interface for Git"
}

helpLongDescription() {
  helpDescription
  echo "Tig is an ncurses-based text-mode interface for git."
  echo "It functions mainly as a Git repository browser, but"
  echo "can also assist in staging changes for commit at chunk"
  echo "level and act as a pager for output from various Git commands."
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- use ${__HELP_EXAMPLE}tig${__RESET_COLOR} command to browse git repository's logs."
  echo "%"
}

# jscpd:ignore-start
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isTestInstallImplemented() { :; }
configure() { :; }
isConfigureImplemented() { :; }
testConfigure() { :; }
isTestConfigureImplemented() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    tig
}

testInstall() {
  Assert::commandExists tig
}
