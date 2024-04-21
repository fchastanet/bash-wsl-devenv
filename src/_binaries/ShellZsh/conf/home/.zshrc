#!/usr/bin/env zsh

# skip if non interactive mode
if [[ $- != *i* ]]; then
  return 0
fi

# compinit
autoload -Uz compinit
if [[ -n ${HOME}/.cache/zsh/zcompdump-$ZSH_VERSION(#qN.mh+24) ]]; then
  compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
else
  compinit -C
fi
zstyle :compinstall filename "${HOME}/.zshrc"
zstyle ':completion:*' menu select

# zinit plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ -f "${ZINIT_HOME}/zinit.zsh" ]; then
  source "${ZINIT_HOME}/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit
  zinit lucid depth=1 light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
fi

# make vi use right keys binding
bindkey -e

# make ctrl-arrow left/right navigate through words
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

loadConfigFiles() {
  local dir="$1"
  local file
  while IFS= read -r file ; do
    # shellcheck source=src/_binaries/MandatorySoftwares/conf/.bash-dev-env/aliases.d/bash-dev-env.sh
    source "${file}"
  done < <("${HOME}/.bash-dev-env/loadConfigFiles" "${dir}" sh zsh || echo)
}

loadConfigFiles "${HOME}/.bash-dev-env/themes.d"
loadConfigFiles "${HOME}/.bash-dev-env/interactive.d"
loadConfigFiles "${HOME}/.bash-dev-env/aliases.d"
loadConfigFiles "${HOME}/.bash-dev-env/completions.d"
