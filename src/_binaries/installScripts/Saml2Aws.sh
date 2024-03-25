#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Saml2Aws
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED Github::upgradeRelease as githubUpgradeRelease
# EMBED "${FRAMEWORK_ROOT_DIR}/src/UI/talk.ps1" as talkScript

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Saml2Aws"
}

helpDescription() {
  echo "Saml2Aws"
}

helpVariables() {
  true
}

listVariables() {
  echo "AWS_AUTHENTICATOR"
  echo "CAN_TALK_DURING_INSTALLATION"
  echo "AWS_APP_ID"
  echo "AWS_PROFILE"
  echo "AWS_USER_MAIL"
  echo "AWS_DEFAULT_REGION"
  echo "AWS_TEST_SECRET_ID"
  echo "AWS_DEFAULT_DOCKER_REGISTRY_ID"
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  if [[ "${AWS_AUTHENTICATOR:-Saml2Aws}" = "Saml2Aws" ]]; then
    fortunes+=("use aws-login alias to log to aws using saml2aws (see https://github.com/Versent/saml2aws)")
    if ! command -v saml2aws &>/dev/null; then
      fortunes+=("\ninstall it using 'installAndConfigure Saml2Aws")
    fi
  fi
}

dependencies() {
  echo "AwsCli"
}

breakOnConfigFailure() {
  echo breakOnConfigFailure
}

breakOnTestFailure() {
  echo breakOnTestFailure
}

install() {

  # @see https://github.com/fchastanet/my-documents/blob/master/HowTo/Saml2Aws.md
  # shellcheck disable=SC2317
  saml2awsInstallCallback() {
    sudo tar xzvf "$1" -C /usr/local/bin saml2aws
    sudo chmod +x /usr/local/bin/saml2aws
    hash -r
  }
  export -f saml2awsInstallCallback
  # shellcheck disable=SC2154
  SUDO=sudo "${embed_function_GithubUpgradeRelease}" \
    /usr/local/bin/saml2aws \
    "https://github.com/Versent/saml2aws/releases/download/v@latestVersion@/saml2aws_@latestVersion@_linux_amd64.tar.gz" \
    "--version" \
    "Version::getCommandVersionFromPlainText" \
    saml2awsInstallCallback \
    "Version::parse"
}

configure() {
  mkdir -p "${USER_HOME}/.aws" || true

  if Assert::wsl; then
    # export display needed
    # @see https://github.com/Versent/saml2aws/issues/561
    DISPLAY="$(ip route show default | awk '/default/ {print $3}'):0.0"
    export DISPLAY
  fi

  if [[ -n "${AWS_APP_ID}" && -n "${AWS_PROFILE}" && -n "${AWS_USER_MAIL}" ]]; then
    Log::displayWarning "Please wait saml2aws configuration finishing ..."
    DBUS_SESSION_BUS_ADDRESS=/dev/null saml2aws configure \
      --idp-provider='AzureAD' \
      --session-duration=43200 \
      --mfa='Auto' \
      --profile="${AWS_PROFILE}" \
      --url='https://account.activedirectory.windowsazure.com' \
      --username="${AWS_USER_MAIL}" \
      --app-id="${AWS_APP_ID}" \
      --skip-prompt
  else
    Log::displaySkipped "saml2aws configuration skipped as AWS_APP_ID, AWS_PROFILE or AWS_USER_MAIL are not provided"
  fi
}

testInstall() {
  Version::checkMinimal "saml2aws" --version "2.36.10" || return 1
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${USER_HOME}/.saml2aws" || ((++failures))

  if [[ "${INSTALL_INTERACTIVE}" = "0" ]]; then
    Log::displaySkipped "saml2aws configuration skipped as INSTALL_INTERACTIVE is set to 0"
  elif [[ -n "${AWS_APP_ID}" && -n "${AWS_PROFILE}" && -n "${AWS_USER_MAIL}" ]]; then
    # try to login
    # shellcheck disable=SC2154
    cp "${embed_file_talkScript}" "${embed_file_talkScript}.ps1"
    UI::talkToUser "Please on Bash Dev env installation, your input may be required" \
      "${embed_file_talkScript}.ps1"
    if ! Retry::parameterized 3 0 \
      "AWS Authentication, please provide your credentials ..." \
      saml2aws login -p "${AWS_PROFILE}" --disable-keychain; then
      ((++failures))
      Log::displayError "Failed to connect to aws"
      return "${failures}"
    fi
    Log::displaySuccess "Aws connection succeeds"

    # try to get secret
    Log::displayInfo "Trying to get secrets from aws"
    if ! aws secretsmanager \
      --region "${AWS_DEFAULT_REGION}" get-secret-value \
      --secret-id "${AWS_TEST_SECRET_ID}" \
      --query SecretString >/dev/null; then
      ((++failures))
      Log::displayError "Failed to connect to aws"
      return "${failures}"
    fi
    Log::displaySuccess "Aws secret retrieved successfully"

    # test docker private registry connection
    if ! command -v docker &>/dev/null; then
      Log::displaySkipped "test docker private registry connection skipped as docker command is missing"
      return "${failures}"
    fi

    Log::displayInfo "Trying to connect docker private registry, please provide password if asked"
    if aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login \
      --username AWS \
      --password-stdin \
      "${AWS_DEFAULT_DOCKER_REGISTRY_ID}"; then
      Log::displaySuccess "docker login success"
    else
      ((++failures))
      Log::displayError "Failed to connect to docker private registry"
    fi
  else
    Log::displaySkipped "saml2aws configuration skipped as AWS_APP_ID, AWS_PROFILE or AWS_USER_MAIL are not provided"
  fi

  return "${failures}"
}
