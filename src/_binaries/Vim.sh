#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Vim
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Vim"
}

helpDescription() {
  echo "Vim"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::installIfNecessary --no-install-recommends \
    vim \
    vim-gui-common \
    vim-runtime

  curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  sudo mkdir -p /root/.vim/autoload
  sudo cp "${HOME}/.vim/autoload/plug.vim" /root/.vim/autoload/plug.vim
}

testInstall() {
  local failures=0
  Assert::commandExists vi || ((++failures))
  Assert::commandExists vim || ((++failures))
  Assert::fileExists "${HOME}/.vim/autoload/plug.vim" || ((++failures))
  SUDO=sudo Assert::fileExists "/root/.vim/autoload/plug.vim" root root || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
