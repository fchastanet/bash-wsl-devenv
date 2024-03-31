#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Vim
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

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
  Linux::Apt::update
  Linux::Apt::install \
    vim \
    vim-gui-common \
    vim-runtime

  curl -fLo "${USER_HOME}/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

testInstall() {
  Assert::commandExists vi
  Assert::commandExists vim
  Assert::fileExists "${USER_HOME}/.vim/autoload/plug.vim"
}

configure() { :; }

testConfigure() { :; }
