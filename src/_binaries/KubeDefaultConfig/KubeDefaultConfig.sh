#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/KubeDefaultConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/KubeDefaultConfig/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "KubeDefaultConfig"
}

helpDescription() {
  echo "KubeDefaultConfig"
}

dependencies() {
  echo "ShellBash"
  echo "Saml2Aws"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

installHelm() {
  if ! command -v helm &>/dev/null; then
    Log::displayInfo "install helm ..."
    Retry::default curl -fsSL https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    Linux::Apt::installIfNecessary --no-install-recommends \
      apt-transport-https
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" |
      sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    Linux::Apt::installIfNecessary --no-install-recommends \
      helm
  fi
}

installKubectl() {
  Log::displayInfo "install kubectl ..."
  local versionUrl="https://storage.googleapis.com/kubernetes-release/release/stable.txt"
  local latestVersion
  latestVersion="$(curl -fsSL "${versionUrl}" | Version::parse)"
  if command -v kubectl &&
    [[ "$(kubectl version --short=true 2>/dev/null | Version::parse)" = "${latestVersion}" ]]; then
    Log::displaySkipped "kubectl version ${latestVersion} already installed"
  else
    Retry::default curl \
      -L \
      -o /tmp/kubectl \
      --fail \
      "https://storage.googleapis.com/kubernetes-release/release/v${latestVersion}/bin/linux/amd64/kubectl"
    sudo chmod +x /tmp/kubectl
    sudo mv /tmp/kubectl /usr/local/bin/kubectl
  fi
}

installKind() {
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/kind \
    "https://github.com/kubernetes-sigs/kind/releases/download/v@latestVersion@/kind-linux-amd64"
}

installMinikube() {
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/minikube \
    "https://github.com/kubernetes/minikube/releases/download/v@latestVersion@/minikube-linux-amd64" \
    version
}

installKubeps1() {
  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/kubeps1" \
    "https://github.com/jonmosco/kube-ps1.git"
}

installKubectx() {
  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/kubectx" \
    "https://github.com/ahmetb/kubectx"

  sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
}

install() {
  installHelm || {
    Log::displayError "Error during helm install"
    return 1
  }
  installKubectl || {
    Log::displayError "Error during kubectl install"
    return 1
  }
  installKind || {
    Log::displayError "Error during kind install"
    return 1
  }
  installMinikube || {
    Log::displayError "Error during minikube install"
    return 1
  } 
  installKubeps1 || {
    Log::displayError "Error during kubeps1 install"
    return 1
  } 
  installKubectx || {
    Log::displayError "Error during kubectx install"
    return 1
  } 
}

testInstall() {
  local -i failures=0
  Version::checkMinimal "helm" "version" "3.14.2" || ((++failures))
  Version::checkMinimal "kubectl" "version" "1.29.1" || ((++failures))
  Version::checkMinimal "kind" "--version" "0.16.0" || ((++failures))
  Version::checkMinimal "minikube" "version" "1.27.1" || ((++failures))
  Assert::commandExists kubectx || ((++failures))
  Assert::commandExists kubens || ((++failures))
  Assert::fileExists /opt/kubeps1/kube-ps1.sh root root || ((++failures))
  return "${failures}"
}

isKubeConfigGenerationAvailable() {
  local type="$1"
  if [[ "${INSTALL_INTERACTIVE}" = "0" ]]; then
    Log::displaySkipped ".kube/config configuration ${type} skipped as INSTALL_INTERACTIVE is set to 0"
    return 1
  fi

  if [[ -z "${KUBE_CONFIG_REGION_CODE}" || -z "${KUBE_CONFIG_CLUSTER_ARN}" ]]; then
    Log::displaySkipped ".kube/config configuration ${type} skipped as KUBE_CONFIG_REGION_CODE or KUBE_CONFIG_CLUSTER_ARN are not provided"
    return 1
  fi
  if command -v aws &>/dev/null; then
    Log::displaySkipped ".kube/config configuration ${type} skipped as aws command is not available"
    return 1
  fi
}

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

  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".kube" || true # ignore if conf override does not define .kube/config

  if [[ ! -f "${USER_HOME}/.kube/config" ]] && isKubeConfigGenerationAvailable "generation"; then
    aws eks update-kubeconfig \
      --region "${KUBE_CONFIG_REGION_CODE}" \
      --name "${KUBE_CONFIG_CLUSTER_ARN}" || return 1
  fi
}

testConfigure() {
  local -i failures=0
  Assert::dirExists "${USER_HOME}/.bash_completion.d" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash_completion.d/kubens" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash_completion.d/kubectx" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/interactive.d/kube-ps1.sh" || ((++failures))
  if isKubeConfigGenerationAvailable "test"; then
    Assert::fileExists "${USER_HOME}/.kube/config" || ((++failures))
  fi

  return "${failures}"
}
