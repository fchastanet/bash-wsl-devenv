#!/bin/bash

# @description select right conf dir depending if file exists either
# in conf.override or conf folder
Conf::dynamicConfDir() {
  local file="$1"
  if [[ -f "${CONF_OVERRIDE_DIR}/${file}" ]]; then
    echo "${CONF_OVERRIDE_DIR}/${file}"
    return 0
  elif [[ -f "${CONF_DIR}/${file}" ]]; then
    echo "${CONF_DIR}/${file}"
    return 0
  fi
  Log::displayWarning "Conf::dynamicConfDir - ${file} does not exist in any config dirs declared"
  return 1
}
