#!/bin/bash

displayFortunes() {
  if [[ -f /etc/fortune-help-commands &&
    -f /etc/fortune-help-commands.dat &&
    "${SHOW_FORTUNES}" = "1" &&
    $- == *i* ]] &&
    command -v fortune &>/dev/null &&
    command -v cowsay &>/dev/null &&
    command -v lolcat &>/dev/null; then
    randomAnimal="$(find /usr/share/cowsay/cows -type f |
      shuf -n 1 | sed -E -e 's#^.+/([^/.]+)\.cow$#\1#')"
    fortune /etc/fortune-help-commands |
      cowsay -f "${randomAnimal}" | lolcat -s 600
    unset randomAnimal
  fi
}
