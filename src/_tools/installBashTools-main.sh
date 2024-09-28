#!/usr/bin/env bash

Git::requireGitCommand
Linux::requireExecutedAsUser

# shellcheck disable=SC2154
Tools::installBashTools "${targetDirectory}"
