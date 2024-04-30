#!/bin/bash

# @description load pageant and ssh key
# you can provide ssh key by env variable SSH_PRIVATE_KEY
# or if empty, file ~/.ssh/id_rsa will be used if present
# @env SSH_PRIVATE_KEY ssh key provided by env variable
# @env AUTHORIZE_SSH_KEY_USAGE if 0, no ssh key is loaded
# @env LOAD_SSH_KEY feature flag used in distro mode
Engine::Config::loadSshKey() {
  if [[ "${LOAD_SSH_KEY:-1}" = "0" ]]; then
    # ignore in distro mode
    return 0
  fi
  if [[ "${AUTHORIZE_SSH_KEY_USAGE:-0}" = "0" ]]; then
    Log::displaySkipped "Ssh key will not be loaded as you set AUTHORIZE_SSH_KEY_USAGE to 0"
    return 0
  fi
  if [[ -n "${SSH_AUTH_SOCK}" && -n "${SSH_AGENT_PID}" ]]; then
    Log::displaySkipped "Ssh agent skipped as variables SSH_AUTH_SOCK and SSH_AGENT_PID are set"
    return 0
  fi

  if [[ -z "${SSH_PRIVATE_KEY}" && ! -f "${HOME}/.ssh/id_rsa" ]]; then
    Log::displayError "File '${HOME}/.ssh/id_rsa' is missing and env variable SSH_PRIVATE_KEY is empty"
    return 1
  fi
  local errorCode=0
  ssh-add -l &>/dev/null || errorCode=$?
  if [[ "${errorCode}" = "2" ]]; then
    # ssh agent is not started
    Log::displayInfo "Starting ssh agent"
    eval "$(ssh-agent)" || return 2
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID
  fi

  if [[ -z "${SSH_PRIVATE_KEY}" ]]; then
    ssh-add "${HOME}/.ssh/id_rsa" || return 3
  else
    ssh-add <(base64 -d <<<"${SSH_PRIVATE_KEY}") || return 3
  fi

  # Check key has been added to ssh agent
  ssh-add -l &>/dev/null || {
    Log::displayError "Your ssh key has not been loaded"
    return 4
  }
}
