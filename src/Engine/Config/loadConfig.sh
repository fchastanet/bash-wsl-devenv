#!/bin/bash

# @description load .env file
# @arg $1 envFile:String the file to load
Engine::Config::loadConfig() {
  if [[ "${BASH_DEV_ENV_CONFIG_LOADED:-0}" = "1" ]]; then
    return 0
  fi
  # @embed "${BASH_DEV_ENV_ROOT_DIR}/.env.template" as envFileTemplate
  local envFile="${BASH_DEV_ENV_ROOT_DIR}/.env"
  # shellcheck disable=SC2154
  Engine::Config::createEnvFileFromTemplate \
    "${envFile}" "${embed_file_envFileTemplate}" || exit 1
  set -o allexport
  # shellcheck source=/.env.template
  source <(echo "${embed_file_envFileTemplate}")
  # shellcheck source=/.env
  source "${BASH_DEV_ENV_ROOT_DIR}/.env"
  set +o allexport
  export STATS_DIR="${LOGS_DIR}/stats"
  if [[ ! -d "${STATS_DIR}" ]]; then
    mkdir -p "${STATS_DIR}" || true
  fi
  export LOGS_INSTALL_SCRIPTS_DIR="${LOGS_DIR}/installScripts"
  if [[ ! -d "${LOGS_INSTALL_SCRIPTS_DIR}" ]]; then
    mkdir -p "${LOGS_INSTALL_SCRIPTS_DIR}" || true
  fi

  # load environment variables ID, VERSION_CODENAME
  Engine::Config::loadOsRelease
  Engine::Config::loadUserVariables

  if ! Engine::Config::checkEnv "${BASH_DEV_ENV_ROOT_DIR}/.env"; then
    Log::displayError "one or more variables are invalid, check above logs and fix '${envFile}' file accordingly"
    return 1
  fi

  Engine::Config::loadHostIp

  Engine::Config::requireWslu

  #Linux::Wsl::initEnv
  Engine::Config::loadWslVariables

  Log::requireLoad

  Engine::Config::loadSshKey

  Engine::Config::loadLocaleConfig

  export BASH_DEV_ENV_CONFIG_LOADED=1
}
