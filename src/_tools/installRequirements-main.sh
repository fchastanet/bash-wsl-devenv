#!/usr/bin/env bash

Linux::requireExecutedAsUser
Git::requireGitCommand

mkdir -p "${BASH_DEV_ENV_ROOT_DIR}/vendor" || true
Git::cloneOrPullIfNoChanges \
  "${BASH_DEV_ENV_ROOT_DIR}/vendor/bash-tools-framework" \
  "https://github.com/fchastanet/bash-tools-framework.git"
