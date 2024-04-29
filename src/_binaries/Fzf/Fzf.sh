#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fzf
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Fzf/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Fzf"
}

helpDescription() {
  echo "fzf is a general-purpose command-line fuzzy finder."
  echo "It's an interactive Unix filter for command-line"
  echo "that can be used with any list; files, command"
  echo "history, processes, hostnames, bookmarks, git"
  echo "commits, etc."
  echo "More info on https://github.com/junegunn/fzf"
}

dependencies() {
  echo "installScripts/Fd"
  echo "installScripts/Bat"
}

# jscpd:ignore-start
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

fortunes() {
  if [[ "${USER_SHELL}" = "/usr/bin/zsh" && -f "${HOME}/.fzf/shell/key-bindings.zsh" ]]; then
    echo "$(scriptName) - Fzf - CTRL-T - Paste the selected file path(s) into the command line"
    echo "%"
    echo "$(scriptName) - Fzf - ALT-C - cd into the selected directory"
    echo "%"
    echo "$(scriptName) - Fzf - CTRL-R - Paste the selected command from history into the command line"
    echo "%"
  fi
}

fzfInstall() {
  sudo tar -xvzf "$1" --directory /usr/local/bin
  sudo chmod +x /usr/local/bin/fzf
  sudo rm -f "$1"
}

install() {
  local -a packages=(
    # tree command is used by some fzf key binding
    tree
    # ripgrep or rg command
    ripgrep
  )
  Linux::Apt::installIfNecessary --no-install-recommends "${packages[@]}"

  # shellcheck disable=SC2317
  installFzf() {
    rm -f \
      "${HOME}/.fzf/bin/fzf" \
      "${HOME}/.fzf."{bash,zsh}
    "${HOME}/.fzf/install" \
      --no-update-rc --no-fish \
      --completion --key-bindings --bin
    "${HOME}/.fzf/bin/fzf" --bash >"${HOME}/.fzf.bash"
    "${HOME}/.fzf/bin/fzf" --zsh >"${HOME}/.fzf.zsh"
  }

  GIT_CLONE_OPTIONS="--depth=1" Git::cloneOrPullIfNoChanges \
    "${HOME}/.fzf" \
    "https://github.com/junegunn/fzf.git" \
    installFzf \
    installFzf
}

testInstall() {
  local -i failures=0
  (
    PATH="${PATH}:${HOME}/.fzf/bin"
    Version::checkMinimal "fzf" --version "0.44.1" || return 1
  ) || {
    Log::displayError "Impossible to load fzf"
    ((++failures))
  }
  Assert::commandExists "rg" || ((++failures))
  Assert::commandExists "tree" || ((++failures))

  return "${failures}"
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.fzf/shell/key-bindings.zsh" || ((++failures))
  Assert::fileExists "${HOME}/.fzf/shell/completion.zsh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/fzf.zsh" || ((++failures))
  Assert::fileExists "${HOME}/.fzf/shell/key-bindings.bash" || ((++failures))
  Assert::fileExists "${HOME}/.fzf/shell/completion.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/fzf.bash" || ((++failures))

  return "${failures}"
}
