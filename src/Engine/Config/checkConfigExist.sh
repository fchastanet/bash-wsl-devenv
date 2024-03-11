#!/bin/bash

envTemplate="$(
  cat <<'EOF'
  .INCLUDE "${BASH_DEV_ENV_ROOT_DIR}/.env.template"
EOF
)"

# @description if .env does not exist, initialize it with .env.template
Engine::Config::checkConfigExist() {
  local envFile="$1"

  if [[ ! -f "${envFile}" ]]; then
    echo "${envTemplate}" >"${envFile}"
    Log::displayError "a default env file has been created, please edit ${envFile}"
    return 1
  fi
}
