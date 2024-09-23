#!/bin/bash

displayFortunes() {
  local randomAnimal
  local myFortuneMsg
  local expression
  local -a expressions=(-b -d -g -p -s -t -w -y)
  local cowCommand
  local -a cowCommands=(cowsay cowthink)
  if [[ -f /etc/fortune-help-commands &&
    -f /etc/fortune-help-commands.dat &&
    "${SHOW_FORTUNES}" = "1" &&
    $- == *i* ]] &&
    command -v fortune &>/dev/null &&
    command -v cowsay &>/dev/null &&
    command -v lolcat &>/dev/null; then
    randomAnimal="$(find /usr/share/cowsay/cows -type f |
      shuf -n 1 | sed -E -e 's#^.+/([^/.]+)\.cow$#\1#')"
    # shellcheck disable=SC2124
    expression="${expressions[@]:$((RANDOM % ${#expressions[@]})):1}"
    # shellcheck disable=SC2124
    cowCommand="${cowCommands[@]:$((RANDOM % ${#cowCommands[@]})):1}"
    myFortuneMsg="$(
      fortune /etc/fortune-help-commands |
        "${cowCommand}" "${expression}" -W 120 -n -f "${randomAnimal}"
    )"
    # display bubble without right border
    sed -En -e '1,/---------/ p' <<<"${myFortuneMsg}" | sed -E -e 's/.$//'
    # display animal using lolcat
    sed -E '1,/---------/d' <<<"${myFortuneMsg}" | lolcat
  fi
}
