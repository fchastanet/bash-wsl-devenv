#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fzf
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Fzf"
}

helpDescription() {
  echo "Fzf"
}

dependencies() {
  echo "Fd"
  echo "Bat"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

fortunes() {
  if command -v fzf &>/dev/null; then
    fortunes+=("Fzf -- fzf - Use CTRL-T - Paste the selected file path(s) into the command line")
    fortunes+=("Fzf -- fzf - Use CTRL-R - search command line from zsh/bash history")
    fortunes+=("Fzf -- fzf - Use ALT-C - easily select sub directory of current directory")
  fi
}

fzfInstall() {
  sudo tar -xvzf "$1" --directory /usr/local/bin
  sudo chmod +x /usr/local/bin/fzf
  sudo rm -f "$1"
}

install() {
  Linux::Apt::update
  Linux::Apt::install \
    tree # tree command is used by some fzf key binding

  Log::displayInfo "install fzf"
  SUDO=sudo INSTALL_CALLBACK=fzfInstall Github::upgradeRelease \
    "/usr/local/bin/fzf" \
    "https://github.com/junegunn/fzf/releases/download/@latestVersion@/fzf-@latestVersion@-linux_amd64.tar.gz"
}

testInstall() {
  Version::checkMinimal "fzf" --version "0.44.1" || return 1
}

configure() { :; }
testConfigure() { :; }
