#!/usr/bin/env bash

declare action=$1
shift || true
case ${action} in
  scriptName)
    echo "Install1 helpVariables"
    ;;
  helpDescription)
     echo "Install1 helpDescription"
    ;;
  listVariables)
    echo "listVariables"
    ;;
  dependencies)
    echo "Install4.sh"
    ;;
  *)
    echo >&2 "invalid action requested: ${action}"
    exit 1
    ;;
esac
