#!/bin/bash

if command -v docker-compose &>/dev/null; then
  alias docker-compose-down-one-service='docker-compose rm -f -s'
fi
