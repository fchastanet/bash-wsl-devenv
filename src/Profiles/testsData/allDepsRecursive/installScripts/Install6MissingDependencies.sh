#!/usr/bin/env bash

declare action=$1
shift || true
case ${action} in
  scriptName)
    echo "Install6 helpVariables"
    ;;
  helpDescription)
     echo "Install6 helpDescription"
    ;;
  listVariables)
    echo "listVariables"
    ;;
  dependencies)
    echo "Missing.sh"
    ;;
  *)
    echo >&2 "invalid action requested: ${action}"
    exit 1
    ;;
esac
