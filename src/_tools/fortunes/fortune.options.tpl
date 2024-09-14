%
declare versionNumber="1.0"
declare copyrightBeginYear="2024"
declare commandFunctionName="fortuneCommand"
declare help="Generate fortune database"
declare longDescription="""
Generate fortune database based on list of softwares or on a profile
"""
%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _includes/install.profile.options.tpl)"

%
Options::generateCommand "${options[@]}"
%

<% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
