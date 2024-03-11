.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%
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
