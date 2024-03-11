%
declare versionNumber="1.0"
declare copyrightBeginYear="2024"
declare commandFunctionName="distroCommand"
declare help="Launch wsl distribution"
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "skip creating distro ${DISTRO_NAME}" \
    --alt "--skip-distro" \
    --alt "-d" \
    --variable-name "optionSkipDistro" \
    --function-name optionSkipDistroFunction

  Options::generateOption \
    --help "skip softwares installation" \
    --alt "--skip-install" \
    --alt "-i" \
    --variable-name "optionSkipInstall" \
    --function-name optionSkipInstallFunction

  Options::generateOption \
    --help "prepare the wsl image for export (remove all sensitive files)" \
    --alt "--export" \
    --alt "-e" \
    --variable-name "optionExport" \
    --function-name optionExportFunction

  Options::generateOption \
    --help "upload the wsl compressed image to s3 bucket" \
    --alt "--upload" \
    --alt "-u" \
    --variable-name "optionUpload" \
    --function-name optionUploadFunction
)
options+=(
  optionSkipDistroFunction
  optionSkipInstallFunction
  optionExportFunction
  optionUploadFunction
)
Options::generateCommand "${options[@]}"
%

upgradeGithubReleaseCommandCallback() {
  if [[ -n "${optionExactVersion}" && -n "${optionMinimalVersion}" ]]; then
    Log::fatal "--exact-version|-e and --minimal-version|-m are mutually exclusive, you cannot use both argument at the same time."
  fi
}

githubUrlPatternArgCallback() {
  if [[ ! "${githubUrlPatternArg}" =~ ^https://github.com/ ]]; then
    Log::fatal "Invalid githubUrlPattern ${githubUrlPatternArg} provided, it should begin with https://github.com/"
  fi
}

targetFileArgCallback() {
  if [[ "${targetFileArg:0:1}" != "/" ]]; then
    targetFileArg="$(pwd)/${targetFileArg}"
  fi
  if ! Assert::validPath "${targetFileArg}"; then
    Log::fatal "File ${targetFileArg} is not a valid path"
  fi
  if ! Assert::fileWritable "${targetFileArg}"; then
    Log::fatal "File ${targetFileArg} is not writable"
  fi
}

<% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
