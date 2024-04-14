#!/bin/zsh

if typeset -f zinit >/dev/null; then
  zinit lucid reset \
    atclone"[[ -z ${commands[dircolors]} ]] && local P=g \
      \${P}sed -i '/DIR/c\DIR 38;5;33;1' LS_COLORS; \
      \${P}dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*:default" list-colors "${(s.:.)LS_COLORS}";' for \
    trapd00r/LS_COLORS
fi
