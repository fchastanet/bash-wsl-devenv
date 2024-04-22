#!/usr/bin/env zsh

# default theme if ZSH_PREFERRED_THEME not provided
ZSH_DEFAULT_THEME=powerlevel10k/powerlevel10k

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

# https://github.com/agkozak/zinit/blob/master/README.md#disabling-system-wide-compinit-call-ubuntu
# Skip the not really helping Ubuntu global compinit
skip_global_compinit=1

# needed for some completion support
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

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
