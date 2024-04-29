#!/usr/bin/env bash

export SCRIPT_NAME="test"
BASH_DEV_ENV_ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)
FRAMEWORK_ROOT_DIR="${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework"
# shellcheck disable=SC2034
srcDir="${BASH_DEV_ENV_ROOT_DIR}/src"
export FRAMEWORK_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
export BASH_FRAMEWORK_DISPLAY_LEVEL=3
export DISPLAY_DURATION=0

# shellcheck source=vendor/bash-tools-framework/src/_includes/_mandatoryHeader.sh
source "${FRAMEWORK_ROOT_DIR}/src/_includes/_mandatoryHeader.sh"

load "${FRAMEWORK_ROOT_DIR}/vendor/bats-support/load.bash"
load "${FRAMEWORK_ROOT_DIR}/vendor/bats-assert/load.bash"
load "${FRAMEWORK_ROOT_DIR}/vendor/bats-mock-Flamefire/load.bash"

# shellcheck source=vendor/bash-tools-framework/src/_standalone/Bats/assert_lines_count.sh
source "${FRAMEWORK_ROOT_DIR}/src/_standalone/Bats/assert_lines_count.sh"
# shellcheck source=vendor/bash-tools-framework/src/Env/__all.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/__all.sh"
# shellcheck source=vendor/bash-tools-framework/src/Log/__all.sh
source "${FRAMEWORK_ROOT_DIR}/src/Log/__all.sh"
# shellcheck source=vendor/bash-tools-framework/src/UI/theme.sh
source "${FRAMEWORK_ROOT_DIR}/src/UI/theme.sh"
# shellcheck source=vendor/bash-tools-framework/src/Assert/tty.sh
source "${FRAMEWORK_ROOT_DIR}/src/Assert/tty.sh"

initLogs() {
  local envFile="$1"
  unset BASH_FRAMEWORK_THEME
  unset BASH_FRAMEWORK_LOG_LEVEL
  unset BASH_FRAMEWORK_DISPLAY_LEVEL
  BASH_FRAMEWORK_ENV_FILES=("${BATS_TEST_DIRNAME}/testsData/${envFile}")
  Env::requireLoad
  Log::requireLoad
}
