#!/usr/bin/env bash

declare action=$1
shift || true
case ${action} in
  scriptName)
    echo "Install3 helpVariables"
    ;;
  helpDescription)
     echo "Install3 helpDescription"
    ;;
  listVariables)
    echo "listVariables"
    ;;
  dependencies)
    ;;
  *)
    echo >&2 "invalid action requested: ${action}"
    exit 1
    ;;
esac
