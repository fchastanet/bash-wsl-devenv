#!/bin/bash

if [[ ! -d "/mnt/wsl/${WSL_DISTRO_NAME}" ]]; then
  mkdir -p "/mnt/wsl/${WSL_DISTRO_NAME}"
  sudo mount --bind / "/mnt/wsl/${WSL_DISTRO_NAME}"
fi
