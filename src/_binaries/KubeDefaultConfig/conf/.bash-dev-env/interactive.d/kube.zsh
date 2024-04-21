#!/usr/bin/env zsh

if typeset -f zinit >/dev/null; then
  zinit lucid depth=1 load light-mode for \
    make'!!alias alias=' OMZP::kubectl \
    make'!!alias alias=' atload"source <(kubectl completion zsh)" OMZP::kubectx \
    OMZP::kube-ps1
fi
