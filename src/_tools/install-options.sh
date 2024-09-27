#!/usr/bin/env bash

helpLongDescriptionFunction() {
  LOAD_SSH_KEY=0 afterParseCallback

  echo "  Install or update softwares (kube, aws, composer, node, ...)."
  echo "  Configure Home environment (git config, kube, motd, ssh, dns, ...)."
  echo "  And check configurations."
  echo
  displayAvailableSoftwares "${INSTALL_SCRIPTS_ROOT_DIR}"
  echo
  local altDir
  for altDir in "${BASH_DEV_ENV_ROOT_DIR}/srcAlt/"*; do
    if [[ ! -d "${altDir}/installScripts" ]]; then
      continue
    fi
    displayAvailableSoftwares "${altDir}/installScripts"
    echo
  done

  profilesHelpList
}
