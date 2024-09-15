#!/usr/bin/env bash

helpDescription() {
  echo "docker-compose tool"
}

install() {
  SUDO=sudo Github::upgradeRelease \
    /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/v@latestVersion@/docker-compose-linux-x86_64"
  sudo rm -f /usr/bin/docker-compose || true
  sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
}

testInstall() {
  Version::checkMinimal "docker-compose" --version "2.23.1" || return 1
}
