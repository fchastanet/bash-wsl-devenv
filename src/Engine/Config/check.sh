#!/bin/bash

# @description check configuration
Engine::Config::check() {
  local envFile="$1"

  # check if ubuntu
  # load environment variables ID, VERSION_CODENAME
  Engine::Config::loadOsRelease
  if ! echo "${ID}" | grep -qEw 'debian|ubuntu'; then
    Log::fatal "This script is built to support only Debian or Ubuntu distributions. You are using ${ID}."
  fi

  ((errorCount = 0)) || true
  # shellcheck disable=SC2153
  if ! Assert::varExistsAndNotEmpty "USER_NAME"; then
    ((errorCount++))
  elif ! getent passwd "${USER_NAME}" 2>/dev/null >/dev/null; then
    Log::displayError "USER_NAME - user '${USER_NAME}' does not exist"
    ((errorCount++))
  fi

  # SSH_LOGIN
  if ! Assert::varExistsAndNotEmpty "SSH_LOGIN"; then
    Log::displaySkipped "Warning ! SSH_LOGIN not provided in ${ROOT_DIR}/.env file"
  elif ! Assert::ldapLogin "${SSH_LOGIN}"; then
    Log::displayError "SSH_LOGIN: invalid ldap login (format expected firstNameLastName) in ${ROOT_DIR}/.env file"
    ((errorCount++))
  fi

  # GIT_USER_NAME
  if ! Assert::varExistsAndNotEmpty "GIT_USER_NAME"; then
    ((errorCount++))
  elif ! Assert::firstNameLastName "${GIT_USER_NAME}"; then
    Log::displayError "GIT_USER_NAME - invalid format, expected : firstName lastName"
    ((errorCount++))
  fi

  # GIT_USER_MAIL
  if ! Assert::varExistsAndNotEmpty "GIT_USER_MAIL"; then
    ((errorCount++))
  elif ! Assert::emailAddress "${GIT_USER_MAIL}"; then
    Log::displayError "GIT_USER_MAIL: invalid email address"
    ((errorCount++))
  fi

  # PROJECTS_DIR
  if ! Assert::varExistsAndNotEmpty "PROJECTS_DIR"; then
    ((errorCount++))
  elif ! mkdir -p "${PROJECTS_DIR}"; then
    Log::displayError "PROJECTS_DIR - impossible to create the directory '${PROJECTS_DIR}'"
    ((errorCount++))
  elif [[ ! -w "${PROJECTS_DIR}" ]]; then
    Log::displayError "PROJECTS_DIR - directory '${PROJECTS_DIR}' is not writable"
    ((errorCount++))
  fi

  # LOGS_DIR
  if ! Assert::varExistsAndNotEmpty "LOGS_DIR"; then
    ((errorCount++))
  elif ! mkdir -p "${LOGS_DIR}"; then
    Log::displayError "LOGS_DIR - impossible to create the directory '${LOGS_DIR}'"
    ((errorCount++))
  elif [[ ! -w "${LOGS_DIR}" ]]; then
    Log::displayError "LOGS_DIR - directory '${LOGS_DIR}' is not writable"
    ((errorCount++))
  fi

  # CONF_DIR
  if ! Assert::varExistsAndNotEmpty "CONF_DIR"; then
    ((errorCount++))
  elif [[ ! -d "${CONF_DIR}" ]]; then
    Log::displayError "CONF_DIR - directory does not exist '${CONF_DIR}'"
    ((errorCount++))
  elif [[ ! -r "${CONF_DIR}" ]]; then
    Log::displayError "CONF_DIR - directory '${CONF_DIR}' is not accessible"
    ((errorCount++))
  fi

  # INSTALL_SCRIPTS_DIR
  if ! Assert::varExistsAndNotEmpty "INSTALL_SCRIPTS_DIR"; then
    ((errorCount++))
  elif [[ ! -d "${INSTALL_SCRIPTS_DIR}" ]]; then
    Log::displayError "INSTALL_SCRIPTS_DIR - directory does not exist '${INSTALL_SCRIPTS_DIR}'"
    ((errorCount++))
  elif [[ ! -r "${INSTALL_SCRIPTS_DIR}" ]]; then
    Log::displayError "INSTALL_SCRIPTS_DIR - directory '${INSTALL_SCRIPTS_DIR}' is not accessible"
    ((errorCount++))
  fi

  # BACKUP_DIR
  if ! Assert::varExistsAndNotEmpty "BACKUP_DIR"; then
    ((errorCount++))
  elif ! mkdir -p "${BACKUP_DIR}"; then
    Log::displayError "BACKUP_DIR - impossible to create the directory '${BACKUP_DIR}'"
    ((errorCount++))
  elif [[ ! -w "${BACKUP_DIR}" ]]; then
    Log::displayError "BACKUP_DIR - directory '${BACKUP_DIR}' is not writable"
    ((errorCount++))
  fi

  if ((errorCount > 0)); then
    Log::displayError "one or more variables are invalid, check above logs and fix ${envFile} file accordingly"
    return 1
  fi
}
