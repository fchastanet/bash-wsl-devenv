#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Profiles/allDepsRecursive.sh
source "${srcDir}/Profiles/allDepsRecursive.sh"

teardown() {
  unstub_all
  rm -f "${BATS_TEST_TMPDIR}/log" || true
}

function Profiles::allDepsRecursiveNoDeps { #@test
  local status=0
  Profiles::allDepsRecursive \
    "${BATS_TEST_DIRNAME}/testsData" "your software selection" \
    &>"${BATS_TEST_TMPDIR}/log" || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/log"
  assert_output ""
  [[ ${#allDepsResultSeen[@]} = 0 ]]
  [[ ${#allDepsResult[@]} = 0 ]]
}

function Profiles::allDepsRecursiveOK { #@test
  local status=0
  Profiles::allDepsRecursive \
    "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" "your software selection" \
    "Install1.sh" &>"${BATS_TEST_TMPDIR}/log" || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/log"
  assert_lines_count 6
  assert_line --index 0 --partial "INFO    - Install1.sh depends on Install4.sh"
  assert_line --index 1 --partial "INFO    - Install4.sh depends on Install2.sh Install3.sh"
  assert_line --index 2 --partial "INFO    - Install2.sh is a dependency of Install4.sh"
  assert_line --index 3 --partial "INFO    - Install3.sh is a dependency of Install4.sh"
  assert_line --index 4 --partial "INFO    - Install4.sh is a dependency of Install1.sh"
  assert_line --index 5 --partial "INFO    - Install1.sh is a dependency of your software selection"

  [[ ${#allDepsResultSeen[@]} = 4 ]]
  [[ "${allDepsResultSeen["Install1.sh"]}" = "stored" ]]
  [[ "${allDepsResultSeen["Install2.sh"]}" = "stored" ]]
  [[ "${allDepsResultSeen["Install3.sh"]}" = "stored" ]]
  [[ "${allDepsResultSeen["Install4.sh"]}" = "stored" ]]
  [[ ${#allDepsResult[@]} = 4 ]]
  [[ "${allDepsResult[0]}" = "Install2.sh" ]]
  [[ "${allDepsResult[1]}" = "Install3.sh" ]]
  [[ "${allDepsResult[2]}" = "Install4.sh" ]]
  [[ "${allDepsResult[3]}" = "Install1.sh" ]]
}

function Profiles::allDepsRecursiveMissingDependencies { #@test
  local status=0
  Profiles::allDepsRecursive \
    "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" "your software selection" \
    "Install5.sh" &>"${BATS_TEST_TMPDIR}/log" || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/log"
  assert_lines_count 3
  assert_line --index 0 --partial "INFO    - Install5.sh depends on Install6MissingDependencies.sh"
  assert_line --index 1 --partial "INFO    - Install6MissingDependencies.sh depends on Missing.sh"
  assert_line --index 2 --partial "ERROR   - Dependency Missing.sh doesn't exist"

  [[ ${#allDepsResultSeen[@]} = 2 ]]
  [[ "${allDepsResultSeen["Install5.sh"]}" = "stored" ]]
  [[ "${allDepsResultSeen["Install6MissingDependencies.sh"]}" = "stored" ]]
  [[ ${#allDepsResult[@]} = 0 ]]
}
