#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# Mandatory packages
CONFIG_LIST+=(
  "ConformanceTest"
  "MandatorySoftwares"
  "WslDefaultConfig"
  "Upgrade"
)

# optional packages
CONFIG_LIST+=(
  "Docker"
  "MotdDefaultConfig"
  "AwsDefaultConfig"
  "DefaultKubeConfig"
  "Fortune"
  "Saml2Aws"
  "ShellBash"
  "BashTools"
  "PreCommitDefaultConfig"
  "CodeCheckers"
  "Oq"
  "PlantUml"
)

# Mandatory packages
CONFIG_LIST+=(
  "Clean"
  "Export"
)
