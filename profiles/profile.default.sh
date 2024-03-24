#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# Mandatory packages
CONFIG_LIST+=(
  "ConformanceTest"
  "Upgrade"
  "MandatorySoftwares"
)

# optional packages
CONFIG_LIST+=(
  "Docker"
  "Motd"
  "AwsCli"
  "Saml2Aws"
)

# Mandatory packages
CONFIG_LIST+=(
  "Clean"
  "Export"
)
