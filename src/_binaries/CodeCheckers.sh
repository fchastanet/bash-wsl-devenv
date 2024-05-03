#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/CodeCheckers
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "CodeCheckers"
}

helpDescription() {
  echo "CodeCheckers"
}

dependencies() {
  echo "installScripts/Hadolint"
  # Go is needed by shfmt
  echo "installScripts/Go"
  # Python is needed by shfmt-py
  echo "installScripts/Python"
  echo "installScripts/NodeDependencies"
  echo "installScripts/Composer"
  echo "installScripts/Shellcheck"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- the following linters are available: ${__HELP_EXAMPLE}hadolint${__RESET_COLOR}, ${__HELP_EXAMPLE}prettier${__RESET_COLOR}, ${__HELP_EXAMPLE}sass-lint${__RESET_COLOR}, ${__HELP_EXAMPLE}stylelint${__RESET_COLOR}, ${__HELP_EXAMPLE}shellcheck${__RESET_COLOR}, ${__HELP_EXAMPLE}phpmd${__RESET_COLOR}, ${__HELP_EXAMPLE}phpcs${__RESET_COLOR}, ${__HELP_EXAMPLE}php-cs-fixer${__RESET_COLOR}, ${__HELP_EXAMPLE}phpstan${__RESET_COLOR}, ${__HELP_EXAMPLE}psalm${__RESET_COLOR}."
  echo "%"
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}hjson${__RESET_COLOR} allows to convert or parse json with comments."
  echo "%"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  Log::displayInfo "Installing python dependencies shfmt-py"
  if [[ -f "${HOME}/.virtualenvs/python3/bin/activate" ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.virtualenvs/python3/bin/activate"
    pip install --user shfmt-py
  else
    Log::displaySkipped "VirtualEnv has not been installed correctly"
    return 1
  fi

  Log::displayInfo "Installing composer dependencies"
  composer global require --dev \
    'squizlabs/php_codesniffer=*' \
    'phpmd/phpmd=*' \
    'friendsofphp/php-cs-fixer=*' \
    'phpstan/phpstan=*' \
    'vimeo/psalm=*'
  composer global update
}

testInstall() {
  local -i failures=0
  Version::checkMinimal "shfmt" --version "3.7.0" || ((++failures))

  # composer dependencies
  # shellcheck source=src/_binaries/Composer/conf/.bash-dev-env/profile.d/composer_path.sh
  source "${HOME}/.bash-dev-env/profile.d/composer_path.sh" || {
    Log::displayError "Composer script failed to install '${HOME}/.bash-dev-env/profile.d/composer_path.sh'"
    ((++failures))
  }
  Version::checkMinimal "phpcs" --version "3.9.0" || ((++failures))
  Version::checkMinimal "phpmd" --version "2.13.0" || ((++failures))
  Version::checkMinimal "php-cs-fixer" --version "3.14.3" || ((++failures))
  Version::checkMinimal "phpstan" --version "1.9.14" || ((++failures))
  Version::checkMinimal "psalm" --version "5.6.0" || ((++failures))

  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
