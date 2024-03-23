#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/MandatorySoftwares
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

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
  return 1
}

breakOnTestFailure() {
  return 1
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
  # shellcheck disable=SC2317
  updateEnvConfig() {
    sudo sed -E -i \
      -e "s#@@@BASH_DEV_ENV_ROOT_DIR@@@#${BASH_DEV_ENV_ROOT_DIR}#g" \
      -e "s#@@@WINDOWS_PROFILE_DIR@@@#${WINDOWS_PROFILE_DIR}#g" \
      "/etc/profile.d/updateEnv.sh"
    Install::setRootExecutableCallback "$@"
  }
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
    "${CONF_DIR}/etc/profile.d/updateEnv.sh" "/etc/profile.d/updateEnv.sh" \
    "root" "root" updateEnvConfig
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

  Assert::fileExists "/etc/profile.d/updateEnv.sh" "root" "root" || ((++failures))
  Log::displayInfo "checking @@@BASH_DEV_ENV_ROOT_DIR@@@ replaced in /etc/profile.d/updateEnv.sh"
  if grep -q -P "@@@BASH_DEV_ENV_ROOT_DIR@@@" "/etc/profile.d/updateEnv.sh"; then
    Log::displayError "String '@@@BASH_DEV_ENV_ROOT_DIR@@@' has not been replaced in file /etc/profile.d/updateEnv.sh"
    ((++failures))
  fi

  Log::displayInfo "checking @@@WINDOWS_PROFILE_DIR@@@ replaced in /etc/profile.d/updateEnv.sh"
  if grep -q -P "@@@WINDOWS_PROFILE_DIR@@@" "/etc/profile.d/updateEnv.sh"; then
    Log::displayError "String '@@@WINDOWS_PROFILE_DIR@@@' has not been replaced in file /etc/profile.d/updateEnv.sh"
    ((++failures))
  fi

  Log::displayInfo "checking ssh login replaced in /etc/profile.d/updateEnv.sh"
  ORIGINAL_SSH_LOGIN="${SSH_LOGIN}"
  testSourceUpdateEnv() {
    (
      # shellcheck source=conf/etc/profile.d/updateEnv.sh
      source "/etc/profile.d/updateEnv.sh"
      [[ "${ORIGINAL_SSH_LOGIN}" = "${SSH_LOGIN}" && -n "${SSH_LOGIN}" ]]
    ) || return 1
  }
  if ! testSourceUpdateEnv; then
    Log::displayError ".env file has not been loaded by /etc/profile.d/updateEnv.sh"
    # shellcheck disable=SC2031
    ((++failures))
  fi

  return "${failures}"
}
