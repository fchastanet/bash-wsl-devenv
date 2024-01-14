#!/bin/bash
set -o errexit
set -o pipefail

UI::drawLine() {
  local character="${1:-#}"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "${character}"
}

Log::displayInfo() {
  echo -e "\e[44m$1\e[0m"
}

Log::displaySuccess() {
  echo -e "\e[32m$1\e[0m"
}

Log::displayError() {
  echo -e "\e[31m$1\e[0m"
}

Log::fatal() {
  Log::displayError "$1"
  exit 1
}

retryParameterized() {
  local maxRetries=$1
  local delayBetweenTries=$2
  local message="$3"
  local retriesCount=1
  shift 3
  while true; do
    if [[ "${message}" != "" ]]; then
      Log::displayInfo "Attempt ${retriesCount}/${maxRetries}: ${message}"
    fi
    if "$@"; then
      break
    elif [[ ${retriesCount} -le ${maxRetries} ]]; then
      if [[ "${message}" = "" ]]; then
        Log::displayError "Command failed. Attempt ${retriesCount}/${maxRetries}:"
      else
        Log::displayError "Command failed."
      fi
      ((retriesCount++))
      sleep "${delayBetweenTries}"
    else
      Log::displayError "The command has failed after ${retriesCount} attempts."
      return 1
    fi
  done
  return 0
}

retry() {
  retryParameterized 5 15 "" "$@"
}

getGithubLatestRelease() {
  retry curl \
    --fail \
    --silent \
    "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' |                      # Pluck JSON value
    sed -E 's/^v(.*)$/\1/'                              # remove v
}

# default callback called to get a version of a software
# shellcheck disable=SC2120
defaultVersion() {
  $1 --version |                                   # Get tag line
    sed -nre 's/[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' # keep only version numbers
}

# upgrade given binary to latest github release
# @param REPO eg: kubernetes-sigs/kind
# @param TARGET_FILE target binary file (eg: /usr/local/bin/kind)
# @param RELEASE_URL github release url (eg: https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64)
#    the placeholder @latestVersion@ will be replaced by the latest release version
# @param versionCallback specify a function to get software version (default: defaultVersion will call software with argument --version)
# @param installCallback specify a callback to install the file retrieved on github (default copy as is and set execution bit)
upgradeGithubRelease() {
  REPO="$1"
  TARGET_FILE="$2"
  RELEASE_URL="$3"
  versionCallback=${4:-defaultVersion}
  installCallback=${5:-}

  latestVersion="$(getGithubLatestRelease "${REPO}")"
  currentVersion="not existing"
  if [[ -f "${TARGET_FILE}" ]]; then
    # shellcheck disable=SC2086
    currentVersion="$(${versionCallback} "${TARGET_FILE}" 2>&1 | grep -oP '[0-9]+\.[0-9]+(\.[0-9]+)' || true)"
  fi
  if [[ "${currentVersion}" = "${latestVersion}" ]]; then
    Log::displayInfo "${TARGET_FILE} version ${latestVersion} already installed"
  else
    Log::displayInfo "Upgrading ${TARGET_FILE} from version ${currentVersion} to ${latestVersion}"
    url="$(echo "${RELEASE_URL}" | sed -E "s/@latestVersion@/${latestVersion}/g")"
    Log::displayInfo "Using url ${url}"
    retry curl \
      -L \
      -o /tmp/newSoftware \
      --fail \
      "${url}"

    # shellcheck disable=SC2086
    if [[ "$(type -t ${installCallback})" = "function" ]]; then
      ${installCallback} "/tmp/newSoftware" "${TARGET_FILE}"
    else
      mkdir -p "$(dirname ${TARGET_FILE})"
      mv /tmp/newSoftware "${TARGET_FILE}"
      chmod +x "${TARGET_FILE}"
      hash -r
    fi
    rm -f /tmp/newSoftware || true
  fi
}

if [[ "$(id -u)" = "0" ]]; then
  Log::fatal "this script should be executed as normal user"
fi

Log::displayInfo "install docker required packages"
retry sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true
retry sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2

Log::displayInfo "install docker apt source list"
source /etc/os-release

retry curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | sudo apt-key add -

echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list

retry sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true

Log::displayInfo "install docker"
retry sudo apt-get install -y \
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
# shellcheck disable=SC2207
WSL_DISTRO_NAME="$(
  IFS='/'
  x=($(wslpath -m /))
  echo "${x[${#x[@]} - 1]}"
)"

if [[ -z "${WSL_DISTRO_NAME}" ]]; then
  Log::fatal "impossible to deduce distribution name"
fi

if [[ ! -d "${DOCKER_DIR}" ]]; then
  sudo mkdir -pm o=,ug=rwx "${DOCKER_DIR}" || exit 1
fi
sudo chgrp docker "${DOCKER_DIR}"
if [[ ! -d "/etc/docker" ]]; then
  sudo mkdir -p /etc/docker || exit 1
fi

# shellcheck disable=SC2174
if [[ ! -f "/etc/docker/daemon.json" ]]; then
  Log::displayInfo "Creating /etc/docker/daemon.json"
  LOCAL_DNS1="$(grep nameserver </etc/resolv.conf | cut -d ' ' -f 2)"
  LOCAL_DNS2="$(ip --json --family inet addr show eth0 | jq -re '.[].addr_info[].local')"
  (
    echo "{"
    echo "  \"hosts\": [\"${DOCKER_HOST}\"],"
    echo "  \"dns\": [\"${LOCAL_DNS1}\", \"${LOCAL_DNS2}\", \"8.8.8.8\", \"8.8.4.4\"]"
    echo "}"
  ) | sudo tee /etc/docker/daemon.json
fi

dockerIsStarted() {
  DOCKER_PS="$(docker ps 2>&1 || true)"
  [[ -S "${DOCKER_SOCK}" && ! "${DOCKER_PS}" =~ "Cannot connect to the Docker daemon" ]]
}
Log::displayInfo "Checking if docker is started ..."
if dockerIsStarted; then
  Log::displaySuccess "Docker connection success"
else
  Log::displayInfo "Starting docker ..."
  sudo rm -f "${DOCKER_SOCK}" || true
  wsl.exe -d "${WSL_DISTRO_NAME}" sh -c "nohup sudo -b dockerd < /dev/null > '${DOCKER_DIR}/dockerd.log' 2>&1"
  if ! dockerIsStarted; then
    Log::fatal "Unable to start docker"
  fi
fi

Log::displayInfo "Installing docker-compose v1"
[[ -f /usr/local/bin/docker-compose ]] && cp /usr/local/bin/docker-compose /tmp/docker-compose
upgradeGithubRelease \
  "docker/compose" \
  "/tmp/docker-compose" \
  "https://github.com/docker/compose/releases/download/v@latestVersion@/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" \
  defaultVersion

sudo mv /tmp/docker-compose /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

Log::displayInfo "Installing docker-compose v2"
# create the docker plugins directory if it doesn't exist yet
mkdir -p "${HOME}/.docker/cli-plugins"
sudo ln -sf /usr/local/bin/docker-compose "${HOME}/.docker/cli-plugins/docker-compose"

echo
UI::drawLine "-"
Log::displayInfo "docker executable path $(command -v docker)"
Log::displayInfo "docker version $(docker --version)"
Log::displayInfo "docker-compose version $(docker-compose --version)"

echo
if [[ "${SHELL}" = "/usr/bin/bash" ]]; then
  Log::displayInfo "Please add these lines at the end of your ~/.bashrc"
elif [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
  Log::displayInfo "Please add these lines at the end of your ~/.zshrc"
else
  Log::displayInfo "Please add these lines at the end of your shell entrypoint (${SHELL})"
fi
echo
echo "export DOCKER_HOST='${DOCKER_HOST}'"
echo "if [[ ! -S '${DOCKER_SOCK}' ]]; then"
echo "   sudo mkdir -pm o=,ug=rwx '${DOCKER_DIR}'"
echo "   sudo chgrp docker '${DOCKER_DIR}'"
echo "   wsl.exe -d '${WSL_DISTRO_NAME}' sh -c 'nohup sudo -b dockerd < /dev/null > \"${DOCKER_DIR}/dockerd.log\" 2>&1'"
echo "fi"
