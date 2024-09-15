#!/usr/bin/env bash

helpDescription() {
  echo "Dockerfile linter, validate inline bash, written in Haskell"
}

install() {
  SUDO=sudo Github::upgradeRelease \
    "/usr/local/bin/hadolint" \
    "https://github.com/hadolint/hadolint/releases/download/v@latestVersion@/hadolint-Linux-x86_64"
}

testInstall() {
  Version::checkMinimal "hadolint" --version "2.12.0" || return 1
}
