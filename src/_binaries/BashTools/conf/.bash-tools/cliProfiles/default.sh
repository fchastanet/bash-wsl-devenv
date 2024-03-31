#!/usr/bin/env bash

# profile always loaded by default
# if you have most of alpine container, consider changing bash by sh

# provide default container in case no container is provided
# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalContainerArg="${finalContainerArg:-node}"

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalUserArg="node"

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalCommandArg=("//bin/bash")
