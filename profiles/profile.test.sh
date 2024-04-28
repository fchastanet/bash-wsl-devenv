#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

CONFIG_LIST=(
  "installScripts/SimpleTest"
  "srcAlt/DependencySample/installScripts/DependencySample"
  "srcAlt/ck_ip_devenv_dependencies/installScripts/GitPrivateKey"
  "srcAlt/ck_ip_devenv_dependencies/installScripts/CKLM"
)
