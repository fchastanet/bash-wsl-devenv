#!/bin/bash

# @description install or update "${USER_HOME}/.bash-dev-env" file
# @env WINDOWS_PROFILE_DIR
# @env BASH_DEV_ENV_ROOT_DIR
# @env USER_HOME
Engine::Config::installBashDevEnv() {
  Log::displayInfo "Creating file '${USER_HOME}/.bash-dev-env/profile.d/00_init.sh'"
  ${SUDO:-} rm -f "${USER_HOME}/.bash-dev-env/profile.d/00_init.sh" || true
  ${SUDO:-} mkdir -p "${USER_HOME}/.bash-dev-env/profile.d"
  (
    echo '#!/bin/bash'
    echo "export BASH_DEV_ENV_ROOT_DIR='${BASH_DEV_ENV_ROOT_DIR}'"
    echo "export WINDOWS_PROFILE_DIR='${WINDOWS_PROFILE_DIR}'"
  ) | ${SUDO:-} tee "${USER_HOME}/.bash-dev-env/profile.d/00_init.sh" >/dev/null
}
