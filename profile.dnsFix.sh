#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# profile to be used with configure

# Dns is experimental, use it if you encounter some dns issues
CONFIG_LIST+=(
  Dns
)
