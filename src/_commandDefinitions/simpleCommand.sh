#!/bin/bash

optionHelpCallback() {
  "{{ .Data.binData.commands.default.functionName }}Help"
  exit 0
}

defaultBeforeParseCallback() {
  Env::requireLoad
  UI::requireTheme
  Log::requireLoad
}

beforeParseCallback() {
  defaultBeforeParseCallback
}

defaultAfterParseCallback() {
  :;
}

afterParseCallback() {
  defaultAfterParseCallback
}

# shellcheck disable=SC2317 # if function is overridden
optionVersionCallback() {
  # shellcheck disable=SC2154
  echo "${SCRIPT_NAME} version {{ .RootData.binData.commands.default.version }}"
  exit 0
}
