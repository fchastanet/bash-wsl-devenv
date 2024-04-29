#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Profiles/loadProfile.sh
source "${srcDir}/Profiles/loadProfile.sh"

# shellcheck source=/src/Profiles/loadProfile.sh
source "${FRAMEWORK_ROOT_DIR}/src/Filters/uniqUnsorted.sh"

setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  logFile=""$(mktemp -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)""

  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
  export BASH_FRAMEWORK_LOG_FILE_MAX_ROTATION=0
}

teardown() {
  unstub_all
  rm -f "${logFile}" || true
}

function Profiles::loadProfile::OK { #@test
  local exitCode=0
  Profiles::loadProfile \
    ${BATS_TEST_DIRNAME}/testsData/profile.test1.sh &>"${BATS_TEST_TMPDIR}/log" || exitCode=$?

  [[ "${exitCode}" = "0" ]] || (echo >&3 "invalid exit code"; exit 1)
  run cat "${BATS_TEST_TMPDIR}/log"
  # shellcheck disable=SC2154
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.test1.sh'"
  [[ "${#CONFIG_LIST[@]}" = "3" ]]
  [[ "${CONFIG_LIST[0]}" = "Install1.sh" ]]
  [[ "${CONFIG_LIST[1]}" = "Install2.sh" ]]
  [[ "${CONFIG_LIST[2]}" = "Install4.sh" ]]
}

function Profiles::loadProfile::Duplicates { #@test
  local exitCode=0
  Profiles::loadProfile \
    ${BATS_TEST_DIRNAME}/testsData/profile.test2Duplicates.sh &>"${BATS_TEST_TMPDIR}/log" || exitCode=$?

  [[ "${exitCode}" = "0" ]] || (echo >&3 "invalid exit code"; exit 1)
  run cat "${BATS_TEST_TMPDIR}/log"
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.test2Duplicates.sh'"
  [[ "${#CONFIG_LIST[@]}" = "3" ]]
  [[ "${CONFIG_LIST[0]}" = "Install4.sh" ]]
  [[ "${CONFIG_LIST[1]}" = "Install1.sh" ]]
  [[ "${CONFIG_LIST[2]}" = "Install2.sh" ]]
}

function Profiles::loadProfile::additionalVariableLoaded { #@test
  local exitCode=0
  Profiles::loadProfile \
    ${BATS_TEST_DIRNAME}/testsData/profile.test2Duplicates.sh &>"${BATS_TEST_TMPDIR}/log" || exitCode=$?

  [[ "${exitCode}" = "0" ]] || (echo >&3 "invalid exit code"; exit 1)
  run cat "${BATS_TEST_TMPDIR}/log"
  assert_lines_count 1
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.test2Duplicates.sh'"
  [[ "${ADDITIONAL_PROFILE_VARIABLE}" = "test" ]]
}

function Profiles::loadProfile::Unknown { #@test
  run Profiles::loadProfile \
    "${BATS_TEST_DIRNAME}/testsData/profile.unknown.sh"

  assert_failure 2
  assert_lines_count 2
  assert_line --index 0 --partial "INFO    - Loading profile '${BATS_TEST_DIRNAME}/testsData/profile.unknown.sh'"
  assert_line --index 1 --partial "profile ${BATS_TEST_DIRNAME}/testsData/profile.unknown.sh not found"
}

function Profiles::loadProfile::MissingProfileArg { #@test
  run Profiles::loadProfile

  assert_failure 1
  assert_lines_count 1
  assert_line --index 0 --partial "ERROR   - This method needs exactly 1 parameter"
}
