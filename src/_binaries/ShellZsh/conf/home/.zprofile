#!/usr/bin/env zsh

# load bash-tools variables
if [[ -f "${HOME}/.bash-tools/.env" ]]; then
  #shellcheck source=/dev/null
  source "${HOME}/.bash-tools/.env"
fi

# load bash-dev-env variables
if [[ -f "${HOME}/fchastanet/bash-dev-env/.env" ]]; then
  #shellcheck source=.env.template
  source "${HOME}/fchastanet/bash-dev-env/.env"
fi

# default theme if ZSH_PREFERRED_THEME not provided
ZSH_ZSH_DEFAULT_THEME=powerlevel10k/powerlevel10k

# environment variables specific to zsh
export XDG_CONFIG_HOME="$HOME/.config/"

loadConfigFiles() {
  local dir="$1"
  local file
  while IFS= read -r file ; do
    # shellcheck source=src/_binaries/MandatorySoftwares/conf/.bash-dev-env/aliases.d/bash-dev-env.sh
    source "${file}"
  done < <("${HOME}/.bash-dev-env/loadConfigFiles" "${dir}" sh zsh || echo)
}

loadConfigFiles "${HOME}/.bash-dev-env/profile.d"
