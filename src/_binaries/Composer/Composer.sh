#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Composer
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Composer/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Composer"
}

helpDescription() {
  echo "Composer"
}

dependencies() {
  echo "Php"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  if command -v composer; then
    # upgrade
    composer global self-update
  else
    # install composer last version
    (
      # shellcheck disable=SC2154
      trap 'rc=$?; rm -f composer-setup.php || true; exit "${rc}"' EXIT
      cd /tmp || exit 1
      EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

      if [[ "${EXPECTED_CHECKSUM}" != "${ACTUAL_CHECKSUM}" ]]; then
        Log::displayError 'Invalid installer checksum'
        exit 1
      fi

      sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet
    )
  fi
}

testInstall() {
  Version::checkMinimal "composer" --version "2.4.3" || ((++failures))
}

configure() {
  # configure composer to be run as normal user
  sudo mkdir -p \
    /usr/local/.composer/cache \
    /usr/local/.composer/vendor \
    "${HOME}/.config"
  sudo chown -R "${USERNAME}":"${USERGROUP}" \
    /usr/local/.composer \
    "${HOME}/.config"

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::dirExists "/usr/local/.composer" || ((++failures))
  Assert::dirExists "${HOME}/.config" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/composer_path.sh" || ((++failures))
  exit "${failures}"
}
