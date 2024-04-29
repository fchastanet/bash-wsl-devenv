#!/usr/bin/env bash

declare action=$1
shift || true
case ${action} in
  scriptName)
    echo "Install5 helpVariables"
    ;;
  helpDescription)
     echo "Install5 helpDescription"
    ;;
  listVariables)
    echo "listVariables"
    ;;
  dependencies)
    echo "Install6MissingDependencies.sh"
    ;;
  *)
    echo >&2 "invalid action requested: ${action}"
    exit 1
    ;;
esac
