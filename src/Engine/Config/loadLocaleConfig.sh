#!/bin/bash

# @description load locale configuration
Engine::Config::loadLocaleConfig() {
  if [[ "${BASH_DEV_ENV_CONFIG_LOADED:-0}" = "1" ]]; then
    return 0
  fi
  if [[ "${LOAD_LOCALE_CONFIG:-1}" = "1" && ! -f "${PERSISTENT_TMPDIR}/localeConfig.initialized" ]]; then
    Log::displayInfo "Initializing locale en_US.UTF-8"
    export PATH="${PATH}:${HOME}/.local/bin"
    sudo sed -E -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    echo 'LANG="en_US.UTF-8"' | sudo tee /etc/default/locale >/dev/null
    echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf >/dev/null
    sudo locale-gen en_US.UTF-8
    sudo dpkg-reconfigure --frontend=noninteractive locales
    export LC_ALL=C
    export LANG=en_US.UTF-8
    export LC_MESSAGES=en_US.UTF-8
    touch "${PERSISTENT_TMPDIR}/localeConfig.initialized"
  fi
}
