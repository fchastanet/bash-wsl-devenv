.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "skip software configuration" \
    --alt "--skip-config" \
    --alt "--skip-configure" \
    --alt "--skip-configuration" \
    --variable-name "SKIP_CONFIGURE" \
    --function-name optionSkipConfigureFunction

  Options::generateOption \
    --help "skip software installation" \
    --alt "--skip-install" \
    --alt "--skip-installation" \
    --variable-name "SKIP_INSTALL" \
    --function-name optionSkipInstallFunction

  Options::generateOption \
    --help "skip software installation test" \
    --alt "--skip-test" \
    --alt "--skip-tests" \
    --variable-name "SKIP_TEST" \
    --function-name optionSkipTestsFunction

  Options::generateOption \
    --help "install the software requested without resolving dependencies" \
    --alt "--skip-dependencies" \
    --alt "--skip-deps" \
    --variable-name "SKIP_DEPENDENCIES" \
    --function-name optionSkipDependenciesFunction

  Options::generateOption \
    --help "prepare the wsl installation for export (remove all sensitive files)" \
    --alt "--prepare-export" \
    --alt "-e" \
    --variable-name "PREPARE_EXPORT" \
    --function-name optionExportFunction

  profileHelp() { :; }
  Options::generateOption \
    --help profileHelp \
    --help-value-name profile \
    --variable-type "String" \
    --alt "--profile" \
    --alt "-p" \
    --callback validateProfile \
    --variable-name "PROFILE" \
    --function-name optionProfileFunction

  softwareArgHelp() { :; }
  Options::generateArg \
    --variable-name "CONFIG_LIST" \
    --min 0 \
    --max -1 \
    --name "softwares" \
    --help softwareArgHelp \
    --function-name softwaresArgFunction
)
options+=(
  optionSkipConfigureFunction
  optionSkipInstallFunction
  optionSkipTestsFunction
  optionSkipDependenciesFunction
  optionExportFunction
)
%

profileHelp() {
  echo "Profile name to use that contains all the softwares to install"
  echo "List of profiles available:"
  echo
  Conf::list "${BASH_DEV_ENV_ROOT_DIR}/profiles" "" ".sh" "-type f" "   - "  | sort | uniq
}

softwareArgHelp() {
  echo "List of softwares to install (--profile option cannot be used in this case)"
  echo "List of softwares available:"
  Conf::list "${BASH_DEV_ENV_ROOT_DIR}/installScripts" "" "" "-type f" "" |
    grep -v -E '^(_.*|MandatorySoftwares)$' | paste -s -d ',' | sed -e 's/,/, /g' || true

}

validateProfile() {
  if [[ ! -f "${BASH_DEV_ENV_ROOT_DIR}/profiles/$2.sh" ]]; then
    Log::fatal "Profile file ${BASH_DEV_ENV_ROOT_DIR}/$2.sh doesn't exist"
  fi
}

export SKIP_INSTALL
export SKIP_CONFIGURE
export SKIP_TEST
export PREPARE_EXPORT
export SKIP_DEPENDENCIES
