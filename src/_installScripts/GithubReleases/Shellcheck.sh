#!/usr/bin/env bash

helpDescription() {
  echo "ShellCheck, a static analysis tool for shell scripts."
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- the following linter is available: ${__HELP_EXAMPLE}shellcheck${__RESET_COLOR}"
  echo "%"
}

shellcheckInstallCallback() {
  local archive="$1"
  local targetFile="$2"
  local version="$3"
  sudo tar -xvJf "${archive}" \
    --strip-components=1 \
    -C "$(dirname "${targetFile}")" \
    "shellcheck-v${version}/shellcheck"
  sudo chmod +x "${targetFile}"
  rm -f "${archive}" || true
}

install() {
  SUDO=sudo INSTALL_CALLBACK=shellcheckInstallCallback Github::upgradeRelease \
    /usr/local/bin/shellcheck \
    "https://github.com/koalaman/shellcheck/releases/download/v@latestVersion@/shellcheck-v@latestVersion@.linux.x86_64.tar.xz"
}

testInstall() {
  Version::checkMinimal "shellcheck" --version "0.10.0" || return 1
}
