#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/PreCommitDefaultConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/PreCommitDefaultConfig/.pre-commit-config-test.yaml" as preCommitConfigTest

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "PreCommitDefaultConfig"
}

helpDescription() {
  echo "PreCommitDefaultConfig"
}

dependencies() {
  echo "PreCommit"
  echo "GitDefaultConfig"
}

fortunes() {
  echo "PreCommit - pre-commit hooks template is automatically applied on git clone or git init"
  echo "%"
  echo "PreCommit - You can disable git hooks template using 'git config --global --unset init.templatedir'"
  echo "%"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
# jscpd:ignore-end

configure() {
  if [[ ! -f "${USER_HOME}/.virtualenvs/python3.9/bin/activate" ]]; then
    Log::displayError "VirtualEnv has not been installed correctly"
    return 1
  fi
  # Load virtualenv
  # shellcheck source=/dev/null
  source "${USER_HOME}/.virtualenvs/python3.9/bin/activate"
  if [[ ! -d "${USER_HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template" ]]; then
    if ! pre-commit init-templatedir -t pre-commit -t pre-push \
      "${USER_HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template"; then
      Log::displayError "Error during precommit template creation"
      return 1
    fi
  fi

  if ! git config --global init.templatedir \
    "${USER_HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template"; then
    Log::displayError "Error during git precommit template initialization"
    return 1
  fi
}

testConfigure() {
  local -i failures=0

  Assert::dirExists "${USER_HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template" || ((++failures))

  Log::displayInfo "check if git init.templatedir correctly set"
  if [[ "$(git config --global --get init.templatedir)" != "${USER_HOME}/.bash-dev-env/GitDefaultConfig/pre-commit-template" ]]; then
    Log::displayError "git init.templatedir has not been correctly set"
    ((++failures))
  fi

  checkGitHooksCreatedOn() {
    local callback=$1
    (
      local tempDir
      tempDir="$(mktemp -d)"
      # shellcheck disable=SC2154
      trap 'rc=$?; rm -Rf "${tempDir}" &>/dev/null || true; exit "${rc}"' EXIT INT TERM ABRT
      ${callback} "${tempDir}"
      if [[ ! -f "${tempDir}/.git/hooks/pre-commit" ]]; then
        Log::displayError "pre-commit hook has not been installed during ${callback}"
        exit 2
      fi
      if [[ ! -f "${tempDir}/.git/hooks/pre-push" ]]; then
        Log::displayError "pre-push hook has not been installed during ${callback}"
        exit 3
      fi
    ) || return 1
  }
  Log::displayInfo "check that git init sets hooks automatically"
  # shellcheck disable=SC2317
  gitInit() { git init "$1"; }
  checkGitHooksCreatedOn gitInit || ((++failures))

  Log::displayInfo "check that git clone sets hooks automatically"
  # shellcheck disable=SC2317
  gitClone() {
    git clone https://github.com/fchastanet/repo-test.git "$1"
  }
  checkGitHooksCreatedOn gitClone || ((++failures))

  Log::displayInfo "check that committing, runs pre-commit hook"
  (
    local tempDir
    tempDir="$(mktemp -d)"
    # shellcheck disable=SC2154
    trap 'rc=$?; rm -Rf "${tempDir}" &>/dev/null || true; exit "${rc}"' EXIT INT TERM ABRT
    cd "${tempDir}"
    git init
    git checkout -b fix/1867
    # shellcheck disable=SC2154
    cp "${embed_file_preCommitConfigTest}" .pre-commit-config.yaml
    echo "test" >test.js
    echo "test" >test.php
    git add test.*
    if git commit -m 'test'; then
      Log::displayError "pre-commit should have prevent the commit"
    else
      Log::displaySuccess "pre-commit has prevented the commit with success"
      if [[ "$(cat test.js)" != "failure" ]]; then
        Log::displayError "pre-commit should have changed content of test.js"
      fi
      if [[ "$(cat test.php)" != "success" ]]; then
        Log::displayError "pre-commit should have changed content of test.php"
      fi
    fi
  ) || ((++failures))

  return "${failures}"
}
