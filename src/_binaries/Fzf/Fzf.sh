#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fzf
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Fzf/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Fzf"
}

helpDescription() {
  echo "fzf is a general-purpose command-line fuzzy finder."
  echo "It's an interactive Unix filter for command-line"
  echo "that can be used with any list; files, command"
  echo "history, processes, hostnames, bookmarks, git"
  echo "commits, etc."
  echo "More info on https://github.com/junegunn/fzf"
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
    echo "Fzf -- fzf - Use CTRL-T - Paste the selected file path(s) into the command line"
    echo "%"
    echo "Fzf -- fzf - Use CTRL-R - search command line from zsh/bash history"
    echo "%"
    echo "Fzf -- fzf - Use ALT-C - easily select sub directory of current directory"
    echo "%"
  fi
}

fzfInstall() {
  sudo tar -xvzf "$1" --directory /usr/local/bin
  sudo chmod +x /usr/local/bin/fzf
  sudo rm -f "$1"
}

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    tree # tree command is used by some fzf key binding

  Log::displayInfo "install fzf"
  SUDO=sudo INSTALL_CALLBACK=fzfInstall Github::upgradeRelease \
    "/usr/local/bin/fzf" \
    "https://github.com/junegunn/fzf/releases/download/@latestVersion@/fzf-@latestVersion@-linux_amd64.tar.gz"
}

testInstall() {
  local -i failures=0
  Version::checkMinimal "fzf" --version "0.44.1" || ((++failures))
  return "${failures}"
}

configure() {
   # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/fzf.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/fzf.fish" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/fzf.zsh" || ((++failures))
  return "${failures}"
}
