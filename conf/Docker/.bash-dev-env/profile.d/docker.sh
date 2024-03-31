#!/bin/bash

if command -v docker &>/dev/null; then
  export DOCKER_HOST='unix:///run/docker.sock'
fi
