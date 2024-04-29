#!/usr/bin/env bash

declare action=$1
shift || true
case ${action} in
  scriptName)
    echo "Install4 helpVariables"
    ;;
  helpDescription)
     echo "Install4 helpDescription"
    ;;
  listVariables)
    echo "listVariables"
    ;;
  dependencies)
    echo "Install2.sh"
    echo "Install3.sh"
    ;;
  *)
    echo >&2 "invalid action requested: ${action}"
    exit 1
    ;;
esac
