#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Font
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/installScripts/Font.ps1" as fontScript
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/Font/.Xresources" as xresources

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Font"
}

helpDescription() {
  echo "Font"
}

helpVariables() {
  true
}

listVariables() {
  true
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  if Assert::wsl; then
    if ! ls "${WINDOWS_PROFILE_DIR}/AppData/Local/Microsoft/Windows/Fonts/mesloLGS_NF"*.ttf &>/dev/null; then
      fortunes+=("Font 'Meslo LG S' does not seem to be installed, use 'install Font' to get better terminal results")
    fi
  fi
}

dependencies() {
  return 0
}

breakOnConfigFailure() {
  echo breakOnConfigFailure
}

breakOnTestFailure() {
  echo breakOnTestFailure
}

install() {
  if ! Assert::wsl; then
    Log::displaySkipped "Font installs only on wsl"
    return 0
  fi

  # shellcheck disable=SC2317
  changeBranchOnSuccess() {
    (
      cd /opt/IlanCosman-tide-fonts || return 1
      sudo git checkout assets
    )
  }

  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/IlanCosman-tide-fonts" \
    "https://github.com/IlanCosman/tide.git" \
    changeBranchOnSuccess \
    changeBranchOnSuccess

  (
    # shellcheck disable=SC2154
    cp "${embed_file_fontScript}" "${TMPDIR:-/tmp}/Font.ps1"
    local tempFolder
    tempFolder="$(mktemp -p "${TMPDIR:-/tmp}" -d)"
    chmod 777 "${tempFolder}"
    cp "/opt/IlanCosman-tide-fonts/fonts/mesloLGS_NF"*.ttf "${tempFolder}"
    cd "${tempFolder}" || exit 1
    powershell.exe -ExecutionPolicy Bypass -NoProfile \
      -Command "$(Linux::Wsl::cachedWslpath -w "${TMPDIR:-/tmp}/Font.ps1")" \
      -verbose "$(Linux::Wsl::cachedWslpath -w "${tempFolder}")"
  )
}

configure() {
  if ! Assert::wsl; then
    Log::displaySkipped "Font installs only on wsl"
    return 0
  fi

  local fileToInstall
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "Font/.Xresources" "embed_file_xresources")" || return 1
  Install::file \
    "${fileToInstall}" "${USER_HOME}/.Xresources" || return 1

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

}

testInstall() {
  Assert::fileExists /opt/IlanCosman-tide-fonts/fonts/mesloLGS_NF_regular.ttf root root ||
    return 1
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${USER_HOME}/.Xresources" || ((++failures))
  local localAppData
  localAppData="$(Linux::Wsl::cachedWslpathFromWslVar LOCALAPPDATA)"
  Assert::fileExists \
    "${localAppData}/Microsoft/Windows/Fonts/mesloLGS_NF_regular.ttf" \
    "${USERNAME}" "${USERGROUP}" || {
    ((++failures))
    Log::displayError "Font mesloLGS_NF_regular.ttf not installed in windows folder: ${localAppData}/Microsoft/Windows/Fonts"
  }
  return "${failures}"
}
