#!/bin/bash

optionHelpCallback() {
  "{{ .Data.binData.commands.default.functionName }}Help"
  exit 0
}

defaultBeforeParseCallback() {
  Env::requireLoad
  UI::requireTheme
  Log::requireLoad
  Linux::requireUbuntu
  Linux::Wsl::requireWsl
}

beforeParseCallback() {
  defaultBeforeParseCallback
}

defaultAfterParseCallback() {
  Engine::Config::loadConfig
}

afterParseCallback() {
  defaultAfterParseCallback
}
