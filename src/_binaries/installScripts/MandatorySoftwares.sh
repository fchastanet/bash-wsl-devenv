#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/MandatorySoftwares
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/home/.bash-dev-env" as bashDevEnv

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "MandatorySoftwares"
}

helpDescription() {
  echo "MandatorySoftwares"
}

helpVariables() {
  true
}

listVariables() {
  true
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  return 0
}

dependencies() {
  echo "WslConfig"
}

breakOnConfigFailure() {
  return 0
}

breakOnTestFailure() {
  return 0
}

install() {
  Linux::Apt::update
  # configure language support
  Linux::Apt::install \
    language-selector-common
  # shellcheck disable=SC2046
  Linux::Apt::install \
    tzdata \
    $(check-language-support)

  PACKAGES=(
    build-essential
    curl
    dos2unix
    jq
    mysql-client
    # net-tools to get netstat
    net-tools
    parallel
    putty-tools
    pv
    # add add-apt-repository
    software-properties-common
    unzip
    vim
    vim-gui-common
    vim-runtime
    wget
  )
  Linux::Apt::install "${PACKAGES[@]}"

}

configure() {
  Engine::Config::installBashDevEnv
}

testInstall() {
  local -i failures=0

  Assert::commandExists "nc" || ((++failures))
  Assert::commandExists "dos2unix" || ((++failures))
  Assert::commandExists "jq" || ((++failures))
  Assert::commandExists "make" || ((++failures))
  Assert::commandExists "unzip" || ((++failures))

  return "${failures}"
}

testConfigure() {
  local -i failures=0

  Assert::fileExists "${USER_HOME}/.bash-dev-env" || ((++failures))
  SUDO=sudo Assert::fileExists "/root/.bash-dev-env" "root" "root" || ((++failures))
  Log::displayInfo "checking BASH_DEV_ENV_ROOT_DIR variable replaced in ${USER_HOME}/.bash-dev-env"
  if ! grep -q -P "BASH_DEV_ENV_ROOT_DIR=${BASH_DEV_ENV_ROOT_DIR}" "${USER_HOME}/.bash-dev-env"; then
    Log::displayError "Variable 'BASH_DEV_ENV_ROOT_DIR' has not been replaced in file ${USER_HOME}/.bash-dev-env"
    ((++failures))
  fi

  Log::displayInfo "checking WINDOWS_PROFILE_DIR replaced in ${USER_HOME}/.bash-dev-env"
  if ! grep -q -P "WINDOWS_PROFILE_DIR=${WINDOWS_PROFILE_DIR}" "${USER_HOME}/.bash-dev-env"; then
    Log::displayError "Variable 'WINDOWS_PROFILE_DIR' has not been replaced in file ${USER_HOME}/.bash-dev-env"
    ((++failures))
  fi

  return "${failures}"
}
