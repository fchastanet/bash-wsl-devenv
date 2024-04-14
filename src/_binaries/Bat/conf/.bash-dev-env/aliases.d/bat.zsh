#!/bin/zsh
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# only for zsh, you can also use global aliases to override -h and --help entirely
# -h disabled as some options are -h without being actually help (eg: ls -h)
#alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
