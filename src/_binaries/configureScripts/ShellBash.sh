#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/ShellBash
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/ShellBash" as shell_bash_dir

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "ShellBash"
}

helpDescription() {
  echo "ShellBash"
}

dependencies() {
  echo Fasd
  echo Fzf
  echo Kubectx
  echo Kubeps1
  # font needed for displaying bash prompt
  echo Font
  echo Vim
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
  local currentUserShell
  currentUserShell="$(grep "^${USERNAME}:" /etc/passwd | awk -F ":" '{print $7}')"
  if [[ "${currentUserShell}" = "/usr/bin/bash" ]]; then
    if command -v zsh &>/dev/null; then
      fortunes+=("Bash is set as default shell, you can switch to zsh using 'chsh -s /usr/bin/zsh'")
    fi
  fi
}

install() {
  Linux::Apt::update
  Linux::Apt::install \
    bash-completion
}

testInstall() {
  Assert::fileExists /etc/profile.d/bash_completion.sh root root || return 1
}

declare -a filesToInstall=(
  ".bash_logout"
  ".bashrc"
  ".profile"
  ".dir_colors"
  ".inputrc"
  ".vimrc"
  ".Xresources"
)

configure() {
  if [[ "${PREFERRED_SHELL}" = "ShellBash" ]]; then
    CURRENT_USER_SHELL="$(grep "^${USERNAME}:" /etc/passwd | awk -F ":" '{print $7}')"
    if [[ "${CURRENT_USER_SHELL}" != "/bin/bash" ]]; then
      usermod --shell /bin/bash "${USERNAME}"
      Log::displayHelp "You have to log in/log out to make bash by default"
    fi
    if command -v zsh &>/dev/null; then
      Log::displayHelp "Bash is set as default shell, you can switch back to zsh using 'chsh -s /usr/bin/zsh'"
    fi
  fi

  mkdir -p "${USER_HOME}/.bash-dev-env/interactive.d" || return 1
  Retry::default curl -o "${USER_HOME}/.bash-dev-env/interactive.d/git-prompt.sh" \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh || return 1

  local configDir
  # shellcheck disable=SC2154
  configDir="$(
    Conf::getOverriddenDir \
      "${embed_dir_shell_bash_dir}" \
      "${CONF_OVERRIDE_DIR}/ShellBash"
  )"
  local file
  for file in "${filesToInstall[@]}"; do
    OVERWRITE_CONFIG_FILES=1 Install::file \
      "${configDir}/${file}" "${USER_HOME}/${file}"
  done

  OVERWRITE_CONFIG_FILES=0 Install::dir \
    "${configDir}" "${USER_HOME}" ".vscode"
  OVERWRITE_CONFIG_FILES=1 Install::dir \
    "${configDir}/.bash-dev-env" "${USER_HOME}/.bash-dev-env" "aliases.d"
  OVERWRITE_CONFIG_FILES=1 Install::dir \
    "${configDir}/.bash-dev-env" "${USER_HOME}/.bash-dev-env" "profile.d"
  OVERWRITE_CONFIG_FILES=1 Install::dir \
    "${configDir}/.bash-dev-env" "${USER_HOME}/.bash-dev-env" "completions.d"

  SUDO=sudo OVERWRITE_CONFIG_FILES=0 Install::file \
    "${configDir}/.vimrc" "/root/.vimrc" root root

  # disable bell
  sudo sed -i -e 's/;set bell-style none/set bell-style none/g' /etc/inputrc

}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${USER_HOME}/.bash-dev-env/interactive.d/git-prompt.sh" || ((++failures))
  local file
  for file in "${filesToInstall[@]}"; do
    Assert::fileExists "${USER_HOME}/${file}" || ((++failures))
  done
  SUDO=sudo Assert::fileExists /root/.vimrc root root || ((++failures))

  Assert::fileExists "${USER_HOME}/.bash-dev-env/aliases.d/colors.sh" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/aliases.d/filesDirectory.sh" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/aliases.d/miscellaneous.sh" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/aliases.d/ssh.sh" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/aliases.d/xserver.sh" || ((++failures))

  Assert::fileExists "${USER_HOME}/.bash-dev-env/completions.d/makeTargets.sh" || ((++failures))

  Assert::fileExists "${USER_HOME}/.vscode/settings.json" || ((++failures))

  # check font in windows terminal configuration
  local terminalConfFile
  # cspell:ignore wekyb, bbwe
  terminalConfFile="${WINDOWS_PROFILE_DIR}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
  if [[ -f "${terminalConfFile}" ]]; then
    if ! grep -q '"face": "MesloLGS NF"' "${terminalConfFile}"; then
      Log::displayHelp "Please change your terminal settings($(Linux::Wsl::cachedWslpath -w "${terminalConfFile}")) to use font 'MesloLGS NF' for wsl profile"
    fi
  else
    Log::displayHelp "please use windows terminal for better shell display results"
  fi

  return "${failures}"
}
