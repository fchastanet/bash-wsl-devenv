#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# shellcheck source=/profile.default.sh
source "$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd)/profile.default.sh"
# profile to be used with configure
# create your own profile and comment the configuration you want to skip

CONFIG_LIST+=(
  Chrome
  Docker
  DockerCompose
  Firefox
  JetBrainsToolbox
  Terminator
  Lxde
)
