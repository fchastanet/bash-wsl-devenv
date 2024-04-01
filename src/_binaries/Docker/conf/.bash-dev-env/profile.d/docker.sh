#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if command -v docker &>/dev/null; then
  export DOCKER_HOST='unix:///run/docker.sock'
fi
