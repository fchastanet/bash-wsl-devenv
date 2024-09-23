#!/usr/bin/env bash

helpDescription() {
  echo "ConformanceTest"
}

helpLongDescription() {
  echo "ConformanceTest checks that environment prerequisites are set correctly"
  echo "It checks also validity of .env file content"
}

# jscpd:ignore-start
dependencies() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
  Log::displayInfo "Linux version : $(lsb_release -a)"

  id1000Reason="it can cause you issues when using some docker applications as some group ids are already set to 1001 in these docker images."
  if [[ "$(id -u "${USERNAME}")" != "1000" ]]; then
    Log::fatal "User ${USERNAME} should have user id 1000, ${id1000Reason}"
  fi

  if [[ "$(id -g "${USERNAME}")" != "1000" ]]; then
    Log::fatal "User ${USERNAME} should have group id 1000, ${id1000Reason}"
  fi

  if ! getent passwd "${USERNAME}" &>/dev/null; then
    Log::fatal "User ${USERNAME} does not exist"
  fi

  if [[ "$(getent passwd "${USERNAME}" | cut -d: -f6)" != "${HOME}" ]]; then
    Log::fatal "Specified User home '${HOME}' of ${USERNAME} is incorrect."
  fi
}

configure() {
  install "$@"
}

testInstall() {
  install "$@"
}

testConfigure() {
  install "$@"
}
