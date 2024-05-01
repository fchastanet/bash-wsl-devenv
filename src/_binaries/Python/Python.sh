#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Python
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Python/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Python"
}

helpDescription() {
  echo "Python"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}virtualenv${__RESET_COLOR} is automatically loaded by ${__HELP_EXAMPLE}~/.bash-dev-env/profile.d/python.sh${__RESET_COLOR}."
  echo "%"
}
# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

isUbuntuMinimum24() {
  Version::compare "${VERSION_ID}" "24.04"
}

install() {
  if isUbuntuMinimum24; then
    installFromUbuntu24
  else
    installFromUbuntu20
  fi
}

installFromUbuntu24() {
  local -a packages=(
    build-essential
    python3
    python-is-python3
    python3-pip
    python3-virtualenv
  )
  Linux::Apt::installIfNecessary --no-install-recommends "${packages[@]}"

  mkdir -p \
    "${HOME}/.local/bin" \
    "${HOME}/.local/lib"

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  # Upgrade of pip packages will be done on subsequent calls during upgrade cron
  upgradePipPackages
}

installFromUbuntu20() {
  SKIP_APT_GET_UPDATE=1 Linux::Apt::addRepository ppa:deadsnakes/ppa
  local -a packages=(
    build-essential
    # libdbus-glib-1-dev needed by dbus-python
    libdbus-glib-1-dev
    # libgirepository1.0-dev needed by dbus-python
    libgirepository1.0-dev
    # libcairo2-dev needed by PyGObject
    libcairo2-dev
    # libkrb5-dev needed by pykerberos
    libkrb5-dev
    python3.9
    python3.9-dev
    # needed by some pip dependencies
    python3-cairo-dev
    python3-dbus
    python3-distutils
    python-is-python3
    python3-pip
  )
  Linux::Apt::installIfNecessary --no-install-recommends "${packages[@]}"

  mkdir -p \
    "${HOME}/.local/bin" \
    "${HOME}/.local/lib"

  # Installing virtualenv
  PIP_REQUIRE_VIRTUALENV=false python -m pip install virtualenv

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  # Upgrade of pip packages will be done on subsequent calls during upgrade cron
  upgradePipPackages
}

removeDuplicatePipPackages() {
  # remove duplicate pip packages with ~ prefix that breaks pip packages upgrade otherwise
  find "${VIRTUAL_ENV}/lib/python3"*/site-packages -name '~*' -exec rm -Rf {} ';' || true
}

testInstall() {
  local -i failures=0
  if isUbuntuMinimum24; then
    Version::checkMinimal "python" "--version" "3.12.3" || ((++failures))
  else
    # since virtualenv is not loaded python 3.9 is not yet available
    Version::checkMinimal "python" "--version" "3.8.10" || ((++failures))
  fi
  Version::checkMinimal "virtualenv" "--version" "20.25.0" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/python.sh" || ((++failures))
  return "${failures}"
}

configure() {
  # create home directory that will receive virtualenv configs
  mkdir -p "${HOME}/.virtualenvs" || true
  mkdir -p "${HOME}/.pip/cache" || true

  # create python3 virtual env
  # virtualenv (for Python 3) and venv (for Python 2)
  # allows you to manage separate package installations
  # for different projects.
  virtualenv --system-site-packages --python=/usr/bin/python3 "${HOME}/.virtualenvs/python3"
  upgradePipPackages
}

upgradePipPackages() {
  if [[ "${PIP_PACKAGES_UPGRADED:-0}" = "1" ]]; then
    return 0
  fi
  if [[ -f "${HOME}/.virtualenvs/python3/bin/activate" ]]; then
    # load this virtualenv
    # shellcheck source=/dev/null
    source "${HOME}/.virtualenvs/python3/bin/activate"

    Log::displayInfo "Upgrading virtualenv pip packages"

    # remove duplicate pip packages with ~ prefix that breaks pip packages upgrade otherwise
    find "$(python -m site --user-site)" -name '~*' -exec rm -Rf {} ';' || true

    # install/upgrade pip
    python -m pip install --upgrade pip
    PIP_PACKAGES_UPGRADED=1
  fi
}

testConfigure() {
  local -i failures=0
  # shellcheck source=/dev/null
  source "${HOME}/.virtualenvs/python3/bin/activate" || ((++failures))
  if isUbuntuMinimum24; then
    Version::checkMinimal "python" "--version" "3.12.3" || ((++failures))
  else
    Version::checkMinimal "python" "--version" "3.9.18" || ((++failures))
  fi
  Version::checkMinimal "pip" "--version" "24.0" || ((++failures))
  [[ "${VIRTUAL_ENV}" = "${HOME}/.virtualenvs/python3" ]] || {
    Log::displayError "Virtualenv has not been loaded correctly"
    ((++failures))
  }
  return "${failures}"
}
