#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# directory navigation (check .inputrc for keyboard shortcuts)
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

# some ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# directory size
function folderSize() {
  sudo find "${1:-.}" -maxdepth 1 -mindepth 1 -print0 | xargs -0 -P 10 -L 1 sudo du -hs
}
alias folder-size='folderSize'
alias folder-size-sorter="folderSize | sort -h"
