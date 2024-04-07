#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/MandatorySoftwares
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/MandatorySoftwares/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "MandatorySoftwares"
}

helpDescription() {
  echo "MandatorySoftwares"
}

dependencies() { :; }
fortunes() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

removeSystemdService() {
  local service="$?"
  Log::displayInfo "remove unneeded systemd service : ${service}"
  if systemctl list-units --full -all | grep -Fq "${service}"; then
    sudo systemctl disable "${service}"
  fi
}

install() {
  # remove unneeded systemd service
  # sshd is not needed and cause port 22 usage conflict
  removeSystemdService ssh.service
  sudo systemctl daemon-reload
  sudo systemctl reset-failed

  Linux::Apt::remove \
    openssh-server

  # configure language support
  Linux::Apt::installIfNecessary --no-install-recommends \
    language-selector-common
  # shellcheck disable=SC2046
  Linux::Apt::installIfNecessary --no-install-recommends \
    tzdata \
    $(check-language-support)

  PACKAGES=(
    build-essential
    cron
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
    wget
  )
  Linux::Apt::installIfNecessary --no-install-recommends "${PACKAGES[@]}"
}

testInstall() {
  local -i failures=0

  Assert::commandExists "nc" || ((++failures))
  Assert::commandExists "dos2unix" || ((++failures))
  Assert::commandExists "jq" || ((++failures))
  Assert::commandExists "make" || ((++failures))
  Assert::commandExists "unzip" || ((++failures))
  if ! PAGER=/usr/bin/cat dpkg -l cron &>/dev/null; then
    Log::displayError "cron is not installed"
    ((++failures))
  fi

  return "${failures}"
}

configureUpdateCron() {
  Log::displayInfo "Install upgrade cron"
  if [[ -z "${PROFILE}" ]]; then
    Log::displayHelp "Please provide a profile to the install command in order to activate automatic upgrade"
  else
    local -a cmd=(
      CAN_TALK_DURING_INSTALLATION=0
      INSTALL_INTERACTIVE=0
      sudo
      -i -n
      -u "${USERNAME}"
      "${BASH_DEV_ENV_ROOT_DIR}/install"
      -p "${PROFILE}"
      --skip-configure --skip-test
    )

    SUDO=sudo Conf::createCron \
      "/etc/cron.weekly/bash-dev-env-upgrade" \
      upgrade-job.log \
      "${cmd[@]}"
  fi

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

configure() {
  Engine::Config::installBashDevEnv
  SUDO=sudo USER_HOME=/root Engine::Config::installBashDevEnv
  configureUpdateCron
  # remove parallel nagware
  mkdir -p "${USER_HOME}/.parallel"
  touch "${USER_HOME}/.parallel/will-cite"
}

testConfigure() {
  local -i failures=0

  local initFile="${USER_HOME}/.bash-dev-env/profile.d/00_init.sh"
  Assert::fileExists "${initFile}" || ((++failures))
  SUDO=sudo Assert::fileExists "/root/.bash-dev-env/profile.d/00_init.sh" root root || ((++failures))
  Log::displayInfo "checking BASH_DEV_ENV_ROOT_DIR variable replaced in ${initFile}"
  if ! grep -q -P "BASH_DEV_ENV_ROOT_DIR='${BASH_DEV_ENV_ROOT_DIR}'" "${initFile}"; then
    Log::displayError "Variable 'BASH_DEV_ENV_ROOT_DIR' has not been replaced in file ${initFile}"
    ((++failures))
  fi

  Log::displayInfo "checking WINDOWS_PROFILE_DIR replaced in ${initFile}"
  if ! grep -q -P "WINDOWS_PROFILE_DIR='${WINDOWS_PROFILE_DIR}'" "${initFile}"; then
    Log::displayError "Variable 'WINDOWS_PROFILE_DIR' has not been replaced in file ${initFile}"
    ((++failures))
  fi

  if [[ -n "${PROFILE}" ]]; then
    Log::displayInfo "checking Upgrade cron configuration"
    Assert::fileExecutable "/etc/cron.weekly/bash-dev-env-upgrade" "root" "root" || ((++failures))
    if ! grep -q -E -e "install -p ${PROFILE}" /etc/cron.weekly/bash-dev-env-upgrade; then
      ((failures++))
      Log::displayError "File /etc/cron.weekly/bash-dev-env-upgrade content invalid"
    fi
  fi
  return "${failures}"
}
