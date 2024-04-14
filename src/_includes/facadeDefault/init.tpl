#!/bin/bash

% if [[ "${LOAD_REQUIRES:-1}" = "1" ]]; then
# REQUIRES
% fi
if Assert::functionExists initFacade; then
  initFacade
fi
% if [[ "${LOAD_CONFIG:-1}" = "1" ]]; then
Engine::Config::loadConfig
.INCLUDE "$(dynamicTemplateDir _includes/sudoerFileManagement.tpl)"
% fi
