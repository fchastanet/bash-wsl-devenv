#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# Mandatory packages
CONFIG_LIST+=(
  "installScripts/ConformanceTest"
  "installScripts/MandatorySoftwares"
  "installScripts/WslDefaultConfig"
  "installScripts/Upgrade"
)

# Code Checkers
CONFIG_LIST+=(
  "installScripts/ComposerDependencies"
  "installScripts/NodeDependencies"
  "installScripts/ShFmt"
  "installScripts/Hadolint"
  "installScripts/Shellcheck"
)

# optional packages
CONFIG_LIST+=(
  "installScripts/Docker"
  "installScripts/MotdDefaultConfig"
  "installScripts/AwsDefaultConfig"
  "installScripts/KubeDefaultConfig"
  "installScripts/JavaSdkManagerDependencies"
  "installScripts/Fortune"
  "installScripts/Saml2Aws"
  "installScripts/ShellZsh"
  "installScripts/BashTools"
  "installScripts/PreCommitDefaultConfig"
  "installScripts/Oq"
  "installScripts/PlantUml"
)

# Mandatory packages
CONFIG_LIST+=(
  "installScripts/Clean"
  "installScripts/Export"
)
