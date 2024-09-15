#!/usr/bin/env zsh

# This plugin adds completion for Git, using the zsh completion
# from git.git folks, which is much faster than the official one
# from zsh. A lot of zsh-specific features are not supported,
# like descriptions for every argument, but everything the bash
# completion has, this one does too (as it is using it behind the
# scenes). Not only is it faster, it should be more robust, and
# updated regularly to the latest git upstream version.

if typeset -f zinit >/dev/null; then
  zinit lucid depth=1 load light-mode for \
    wait as"completion" OMZP::gitfast
fi
