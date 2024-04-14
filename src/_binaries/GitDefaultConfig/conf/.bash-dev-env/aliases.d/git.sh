#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

UI::askYesNo() {
  while true; do
    read -p "$1 (y or n)? " -n 1 -r
    echo # move to a new line
    case ${REPLY} in
      [yY]) return 0 ;;
      [nN]) return 1 ;;
      *)
        read -r -N 10000000 -t '0.01' || true # empty stdin in case of control characters
        # \\r to go back to the beginning of the line
        Log::displayError "\\r invalid answer                                                          "
        ;;
    esac
  done
}

# undo last pushed commit
# - step 1: remove commit locally
# - step 2: force-push the new HEAD commit
# !!!! use it with care
# this will create an "alternate reality" for people who have already fetch/pulled/cloned from the remote repository.
gitUndoLastPushedCommit() {
  echo -e '\e[33m!!! use it with care\e[0m'
  echo -e '\e[33mThis will create an "alternate reality" for people who have already fetch/pulled/cloned from the remote repository.\e[0m'
  UI::askYesNo "do you confirm" && {
    git reset HEAD^ && git push origin +HEAD
  }
}
alias gitUndoLastPushedCommit='gitUndoLastPushedCommit'
