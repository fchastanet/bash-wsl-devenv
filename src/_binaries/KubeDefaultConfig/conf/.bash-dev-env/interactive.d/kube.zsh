#!/bin/zsh

# do not set aliases
save_aliases=$(alias -L)
__zinit_kube_plugin_loaded_callback() {
  unalias -m '*'; eval ${save_aliases}; unset save_aliases
  source <(kubectl completion zsh)
}
zinit wait lucid for \
  OMZP::kubectl \
  atload"__zinit_kube_plugin_loaded_callback" \
  OMZP::kubectx \
  OMZP::kube-ps1
