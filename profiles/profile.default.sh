#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

CONFIG_LIST=(
  "MinimumRequirements"
  "Upgrade"
  "MandatorySoftwares"
  "Clean"
)
