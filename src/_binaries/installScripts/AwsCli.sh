#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/AwsCli
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/home/.aws/config" as aws_config

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "AwsCli"
}

helpDescription() {
  echo "AwsCli"
}

helpVariables() {
  true
}

listVariables() {
  echo "AWS_USER_MAIL"
  echo "USER_HOME"
  echo "USERNAME"
  echo "USERGROUP"
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  if ! command -v aws &>/dev/null; then
    echo "aws -- AwsCli not installed - install it using '${BASH_DEV_ENV_ROOT_DIR}/installScripts/AwsCli'"
  fi
}

dependencies() {
  return 0
}

breakOnConfigFailure() {
  echo breakOnConfigFailure
}

breakOnTestFailure() {
  echo breakOnTestFailure
}

install() {
  # install aws-cli
  if [[ -f "/usr/local/bin/aws" && -z "$(find /usr/local/bin/aws -mtime +6)" ]]; then
    Log::displaySkipped "aws-cli installed as binary not older than 6 days"
    exit 0
  fi

  (
    cd /tmp || exit 1
    rm -Rf ./aws
    Retry::default curl \
      --fail \
      -o "awscli.zip" \
      "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    unzip -o awscli.zip >/dev/null
    if [[ -f /usr/local/bin/aws ]]; then
      sudo ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin --update
    else
      sudo ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin
    fi
    rm -Rf ./aws
    rm -f awscli.zip
  )
}

configure() {
  # shellcheck disable=SC2317
  configureAwsConfig() {
    sed -i -E \
      -e "s#azure_default_username=.+\$#azure_default_username=${AWS_USER_MAIL}#" \
      "${USER_HOME}/.aws/config"
    Install::setUserRightsCallback "$@"
  }
  local fileToInstall
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "home/.aws/config" "${embed_file_aws_config}")" || return 1
  Install::file "${fileToInstall}" "${USER_HOME}/.aws/config" "${USERNAME}" "${USERGROUP}" configureAwsConfig
}

testInstall() {
  Version::checkMinimal "aws" --version "2.13.32" || ((++failures))
}

testConfigure() {
  Assert::fileExists "${USER_HOME}/.aws/config" "${USERNAME}" "${USERGROUP}" || return 1

  if grep -q -E -e "azure_default_username=.+$" "${USER_HOME}/.aws/config"; then
    # case where .aws/config has been overridden in conf_override folder
    local azureUserName
    azureUserName="$(sed -nr 's/azure_default_username=(.*)$/\1/p' "${USER_HOME}/.aws/config")"
    if [[ -z "${azureUserName}" ]]; then
      ((++failures))
      Log::displayError "empty azure_default_username in '${USER_HOME}/.aws/config'"
    elif [[ "${azureUserName}" != "${AWS_USER_MAIL}" ]]; then
      Log::displayWarning "azureUserName is not the same as AWS_USER_MAIL in ${BASH_DEV_ENV_ROOT_DIR}/.env"
    fi
  elif ! grep -q -E -e "^\[default\]$" "${USER_HOME}/.aws/config"; then
    ((++failures))
    Log::displayError "default configuration not found in '${USER_HOME}/.aws/config'"
  fi

return "${failures}"

}
