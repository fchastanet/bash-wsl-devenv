#!/bin/bash

if [[ -f /etc/fortune-help-commands && -f /etc/fortune-help-commands.dat && "${SHOW_FORTUNES}" = "1" ]]; then
  randomAnimal="$(find /usr/share/cowsay/cows -type f | shuf -n 1 | sed -E -e 's#^.+/([^/.]+)\.cow$#\1#')"
  fortune /etc/fortune-help-commands | cowsay -f "${randomAnimal}" | lolcat -s 600
fi
