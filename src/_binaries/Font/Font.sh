#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Font
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Font/Font.ps1" as fontScript

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Font"
}

helpDescription() {
  echo "Font"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

fortunes() {
  if Assert::wsl; then
    if ! ls "${WINDOWS_PROFILE_DIR}/AppData/Local/Microsoft/Windows/Fonts/mesloLGS_NF"*.ttf &>/dev/null; then
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- The font ${__HELP_EXAMPLE}Meslo LG S${__RESET_COLOR} does not seem to be installed, use ${__HELP_EXAMPLE}installAndConfigure Font${__RESET_COLOR} to get better terminal results."
      echo "%"
    fi
  fi
}

install() {
  if ! Assert::wsl; then
    Log::displaySkipped "Font installs only on wsl"
    return 0
  fi

  SUDO=sudo GIT_CLONE_OPTIONS="--depth=1 --branch assets" Git::cloneOrPullIfNoChanges \
    "/opt/IlanCosman-tide-fonts" \
    "https://github.com/IlanCosman/tide.git"

  local fontDir
  Linux::Wsl::cachedWslpath2 fontDir -w "${TMPDIR:-/tmp}/Font.ps1"
  local windowsTempDir
  Linux::Wsl::cachedWslpath2 windowsTempDir -w "${tempFolder}"
  (
    # shellcheck disable=SC2154
    cp "${embed_file_fontScript}" "${TMPDIR:-/tmp}/Font.ps1"
    local tempFolder
    tempFolder="$(mktemp -p "${TMPDIR:-/tmp}" -d)"
    chmod 777 "${tempFolder}"
    cp "/opt/IlanCosman-tide-fonts/fonts/mesloLGS_NF"*.ttf "${tempFolder}"
    cd "${tempFolder}" || exit 1
    powershell.exe -ExecutionPolicy Bypass -NoProfile \
      -Command "${fontDir}" \
      -verbose "${windowsTempDir}"
  )
}

testInstall() {
  local -i failures=0

  USERNAME="" USERGROUP="" Assert::fileExists /opt/IlanCosman-tide-fonts/fonts/mesloLGS_NF_regular.ttf || ((++failures))

  local localAppData
  Linux::Wsl::cachedWslpathFromWslVar2 localAppData LOCALAPPDATA
  USERNAME="" USERGROUP="" Assert::fileExists "${localAppData}/Microsoft/Windows/Fonts/mesloLGS_NF_regular.ttf" || {
    ((++failures))
    Log::displayError "Font mesloLGS_NF_regular.ttf not installed in windows folder: ${localAppData}/Microsoft/Windows/Fonts"
  }
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
