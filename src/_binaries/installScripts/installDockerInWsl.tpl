#!/bin/bash

%
declare versionNumber="1.0"
declare copyrightBeginYear="2024"
declare commandFunctionName="distroCommand"
declare help="install docker"
declare longDescription="""
install docker and docker-compose inside wsl
"""
%

.INCLUDE "$(dynamicTemplateDir _includes/install.default.options.tpl)"
