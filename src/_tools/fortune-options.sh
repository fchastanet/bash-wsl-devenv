#!/bin/bash

helpLongDescriptionFunction() {
  LOAD_SSH_KEY=0 afterParseCallback

  echo "  Generate fortune database based on list of softwares or on a profile."
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
