#!/usr/bin/env zsh

# skip if non interactive mode
if [[ $- != *i* ]]; then
  return 0
fi

# needed for some completion support
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

### Added by Zinit's installer
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
### End of Zinit's installer chunk

# compinit
autoload -Uz compinit
if [[ -n ${HOME}/.cache/zsh/zcompdump-$ZSH_VERSION(#qN.mh+24) ]]; then
  compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
else
  compinit -C
fi
zstyle :compinstall filename "${HOME}/.zshrc"
zstyle ':completion:*' menu select

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
  done < <("${HOME}/.bash-dev-env/findConfigFiles" "${dir}" sh zsh || echo)
}

loadConfigFiles "${HOME}/.bash-dev-env/themes.d"
loadConfigFiles "${HOME}/.bash-dev-env/interactive.d"
loadConfigFiles "${HOME}/.bash-dev-env/aliases.d"
loadConfigFiles "${HOME}/.bash-dev-env/completions.d"
