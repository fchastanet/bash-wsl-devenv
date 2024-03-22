#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Docker
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED Github::upgradeRelease as githubUpgradeRelease

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Docker"
}

helpDescription() {
  echo "install docker and docker-compose inside wsl"
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
  echo "MandatorySoftwares"
  echo "WslConfig"
}

breakOnConfigFailure() {
  return 0
}

breakOnTestFailure() {
  return 0
}

# REQUIRE Linux::requireUbuntu
# REQUIRE Linux::requireExecutedAsUser
install() {
  Log::displayInfo "install docker required packages"
  Linux::Apt::update
  Linux::Apt::install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2

  # Docker utilizes iptables to implement network isolation.
  # For good reason, Debian uses the more modern nftables, but this means
  # that Docker cannot automatically tweak the Linux firewall.
  # Given this, you probably want to configure Debian to use the legacy
  # iptables by default
  sudo update-alternatives --set iptables /usr/sbin/iptables-legacy

  Log::displayInfo "install docker apt source list"
  Retry::default curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | sudo apt-key add -
  local dockerSource="deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable"
  if ! grep -q "${dockerSource}" "/etc/apt/sources.list.d/docker.list"; then
    echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
    Linux::Apt::update
  fi

  Log::displayInfo "install docker"
  Retry::default sudo apt-get install -y \
    containerd.io \
    docker-ce \
    docker-ce-cli

  USERNAME="$(id -un)"
  Log::displayInfo "allowing user '${USERNAME}' to use docker"
  sudo getent group docker >/dev/null || sudo groupadd docker || true
  sudo usermod -aG docker "${USERNAME}" || true

  Log::displayInfo "Configure dockerd"
  # see https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9
  # see https://dev.solita.fi/2021/12/21/docker-on-wsl2-without-docker-desktop.html
  DOCKER_DIR="/var/run/docker-data"
  DOCKER_SOCK="${DOCKER_DIR}/docker.sock"
  DOCKER_HOST="unix://${DOCKER_SOCK}"
  export DOCKER_HOST

  if [[ ! -d "${DOCKER_DIR}" ]]; then
    sudo mkdir -pm o=,ug=rwx "${DOCKER_DIR}" || exit 1
  fi
  sudo chgrp docker "${DOCKER_DIR}"
  if [[ ! -d "/etc/docker" ]]; then
    sudo mkdir -p /etc/docker || exit 1
  fi

  # # shellcheck disable=SC2174
  # if [[ ! -f "/etc/docker/daemon.json" ]]; then
  #   Log::displayInfo "Creating /etc/docker/daemon.json"
  #   LOCAL_DNS1="$(grep nameserver </etc/resolv.conf | cut -d ' ' -f 2)"
  #   LOCAL_DNS2="$(ip --json --family inet addr show eth0 | jq -re '.[].addr_info[].local')"
  #   (
  #     echo "{"
  #     echo "  \"hosts\": [\"${DOCKER_HOST}\"],"
  #     echo "  \"dns\": [\"${LOCAL_DNS1}\", \"${LOCAL_DNS2}\", \"8.8.8.8\", \"8.8.4.4\"]"
  #     echo "}"
  #   ) | sudo tee /etc/docker/daemon.json
  # fi

  Log::displayInfo "Installing docker-compose"
  # shellcheck disable=SC2154
  SUDO=sudo "${embed_function_GithubUpgradeRelease}" \
    /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/@latestVersion@/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" \
    "--version" \
    defaultVersion

  rm -f /usr/bin/docker-compose || true
  sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
}

configure() {
  Log::displayInfo "Configuring docker-compose as docker plugin"
  # create the docker plugins directory if it doesn't exist yet
  # shellcheck disable=SC2153
  mkdir -p "${USER_HOME}/.docker/cli-plugins"
  rm -f "${HOME}/.docker/cli-plugins/docker-compose" || true
  sudo ln -sf /usr/local/bin/docker-compose "${HOME}/.docker/cli-plugins/docker-compose"
}

testInstall() {
  local -i failures=0

  if ! Linux::isSystemdRunning; then
    if grep -q -E '^systemd=true' /etc/wsl.conf; then
      Log::fatal "You need to restart wsl by running 'wsl --shutdown' from powershell and re-run this script, in order to start with systemd"
    else
      Log::fatal "/etc/wsl.conf has not been updated with systemd=true instruction, please check this install logs"
    fi
  fi

  Version::checkMinimal "docker" "docker --version" "25.0.3" || ((++failures))
  Version::checkMinimal "docker-compose" "docker-compose --version" "2.23.1" || ((++failures))

  echo
  UI::drawLine "-"
  Log::displayInfo "docker executable path $(command -v docker || true)"
  Log::displayInfo "docker version $(docker --version || true)"
  Log::displayInfo "docker-compose version $(docker-compose --version || true)"

  dockerIsStarted() {
    DOCKER_PS="$(docker ps 2>&1 || true)"
    [[ -S "${DOCKER_SOCK}" && ! "${DOCKER_PS}" =~ "Cannot connect to the Docker daemon" ]]
  }
  Log::displayInfo "Checking if docker is started ..."
  if dockerIsStarted; then
    Log::displaySuccess "Docker connection success"
  else
    Log::displayError "Docker is not started"
    ((++failures))
  fi
  return "${failures}"
}

testConfigure() {
  local -i failures=0

  Log::displayInfo "check if docker-compose binary is working"
  if ! docker-compose version &>/dev/null; then
    Log::displayError "docker-compose failure"
    ((++failures))
  fi

  Log::displayInfo "check if docker compose plugin is installed"
  if [[ ! -f "${HOME}/.docker/cli-plugins/docker-compose" ]]; then
    Log::displayError "docker compose plugin not installed in folder ${HOME}/.docker/cli-plugins/"
    ((++failures))
  fi

  Log::displayInfo "check if docker compose plugin is working"
  if ! docker compose version &>/dev/null; then
    Log::displayError "docker compose plugin failure"
    ((++failures))
  fi

  Log::displayInfo "check if docker dns is working"
  docker run busybox ping google.com -c 1 &>/dev/null || {
    ((++failures))
    Log::displayError "google.com is not reachable from docker, dns issue ?"
    ping google.com -c 1 &>/dev/null || {
      Log::displayError "google.com is not reachable from host neither"
      ((++failures))
    }
  }

  return "${failures}"
}
