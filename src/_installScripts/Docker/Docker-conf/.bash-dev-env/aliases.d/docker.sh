#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if command -v docker-compose &>/dev/null; then
  alias docker-compose-down-one-service='docker-compose rm -f -s'
fi
