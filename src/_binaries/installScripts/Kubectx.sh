#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Kubectx
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Kubectx"
}

helpDescription() {
  echo "Kubectx"
}

helpVariables() {
  true
}

listVariables() {
  true
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  return 0
}

dependencies() {
  return 0
}

breakOnConfigFailure() {
  echo breakOnConfigFailure
}

breakOnTestFailure() {
  echo breakOnTestFailure
}

install() {
  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/kubectx" \
    "https://github.com/ahmetb/kubectx"

  sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
}

configure() {
  mkdir -p "${USER_HOME}/.bash_completion.d" || true
  chown "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d"

  ln -sf /opt/kubectx/completion/kubens.bash "${USER_HOME}/.bash_completion.d/kubens"
  chown -h "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d/kubens"
  ln -sf /opt/kubectx/completion/kubectx.bash "${USER_HOME}/.bash_completion.d/kubectx"
  chown -h "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d/kubectx"
}

testInstall() {
  local -i failures=0
  Assert::commandExists kubectx || ((++failures))
  Assert::commandExists kubens || ((++failures))
  return "${failures}"
}

testConfigure() {
  local -i failures=0
  Assert::dirExists "${USER_HOME}/.bash_completion.d" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash_completion.d/kubens" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash_completion.d/kubectx" || ((++failures))
  return "${failures}"
}
