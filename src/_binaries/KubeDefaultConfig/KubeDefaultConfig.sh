#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/DefaultKubeConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/KubeDefaultConfig/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "DefaultKubeConfig"
}

helpDescription() {
  echo "DefaultKubeConfig"
}

dependencies() {
  echo "ShellBash"
  echo "Kubectx"
  echo "Kubeps1"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
# jscpd:ignore-end

configure() {
  mkdir -p "${USER_HOME}/.bash_completion.d" || true
  chown "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d"

  ln -sf /opt/kubectx/completion/kubens.bash "${USER_HOME}/.bash_completion.d/kubens"
  chown -h "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d/kubens"
  ln -sf /opt/kubectx/completion/kubectx.bash "${USER_HOME}/.bash_completion.d/kubectx"
  chown -h "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d/kubectx"

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::dirExists "${USER_HOME}/.bash_completion.d" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash_completion.d/kubens" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash_completion.d/kubectx" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/interactive.d/kube-ps1.sh" || ((++failures))
  return "${failures}"
}
