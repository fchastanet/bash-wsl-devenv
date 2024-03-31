#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/GitDefaultConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/GitDefaultConfig/conf" as gitconfig_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "GitDefaultConfig"
}

helpDescription() {
  echo "GitDefaultConfig"
}

dependencies() {
  echo "ShellBash"
  echo "Tig"
}

fortunes() {
  fortunes+=("GitDefaultConfig - default main branch is set to $(git config --global --get init.defaultBranch), you can change it in your ~/.gitconfig")
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
  local configDir
  # shellcheck disable=SC2154
  configDir="$(
    Conf::getOverriddenDir \
      "${embed_dir_gitconfig_dir}" \
      "${CONF_OVERRIDE_DIR}/GitDefaultConfig"
  )"

  OVERWRITE_CONFIG_FILES=0 Install::file \
    "${configDir}/.gitconfig" "${USER_HOME}/.gitconfig"
  OVERWRITE_CONFIG_FILES=0 Install::file \
    "${configDir}/.tigrc" "${USER_HOME}/.tigrc"
  OVERWRITE_CONFIG_FILES=0 Install::dir \
    "${configDir}/.config" "${USER_HOME}/.config" "tig"
  OVERWRITE_CONFIG_FILES=0 Install::dir \
    "${configDir}/.bash-dev-env" "${USER_HOME}/.bash-dev-env" "GitDefaultConfig"
  OVERWRITE_CONFIG_FILES=1 Install::dir \
    "${configDir}/.bash-dev-env" "${USER_HOME}/.bash-dev-env" "aliases.d"

  # updateGitDefaultConfig
  if [[ -n "${GIT_USERNAME}" ]]; then
    git config --global user.name "${GIT_USERNAME}"
  fi
  if [[ -n "${GIT_USER_MAIL}" ]]; then
    git config --global user.email "${GIT_USER_MAIL}"
  fi

  if [[ -f "${BASE_MNT_C}/Program Files (x86)/Meld/Meld.exe" ]]; then
    Log::displayInfo "Configuring meld as default diff tool"
    git config --global diff.tool meld
    git config --global alias.dt 'difftool -d'
    sudo ln -sf "${BASE_MNT_C}/Program Files (x86)/Meld/Meld.exe" /usr/local/bin/meld
  else
    Log::displayHelp "GitDefaultConfig - windows meld is not installed, it could have been linked into wsl as git diff"
  fi

  # add github.com to the list of known hosts
  HOME="${USER_HOME}" Ssh::fixAuthenticityOfHostCantBeEstablished "github.com"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${USER_HOME}/.gitconfig" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/GitDefaultConfig/.gitconfig" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/GitDefaultConfig/gitignore" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/aliases.d/git.sh" || ((++failures))
  Assert::fileExists "${USER_HOME}/.config/tig/config" || ((++failures))
  Assert::fileExists "${USER_HOME}/.tigrc" || ((++failures))

  # git config
  local gitUserName
  gitUserName="$(git config --global --get user.name)"
  Log::displayInfo "check git user name validity '${gitUserName}'"
  if [[ -z "${gitUserName}" ]]; then
    Log::displayError "empty git user name"
    ((++failures))
  fi
  if [[ "${gitUserName}" != "${GIT_USERNAME}" ]]; then
    Log::displayWarning "git user name is not the same as GIT_USERNAME in ${BASH_DEV_ENV_ROOT_DIR}/.env"
  fi

  local gitEmail
  gitEmail="$(git config --global --get user.email)"
  Log::displayInfo "check git user email validity '${gitEmail}'"
  if [[ -z "${gitEmail}" ]]; then
    Log::displayError "empty git user email"
    ((++failures))
  fi
  if [[ "${gitEmail}" != "${GIT_USER_MAIL}" ]]; then
    Log::displayWarning "git user email is not the same as GIT_USER_MAIL in ${BASH_DEV_ENV_ROOT_DIR}/.env"
  fi

  return "${failures}"
}
