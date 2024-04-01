#!/bin/bash
###############################################################################
# AVOID EDITING THIS FILE 
# PREFER to add files in dedicated sections of ~/.bash-dev-env
# CHECK ~/.bash-dev-env/README.md
###############################################################################

# ~/.bashrc: executed by bash(1) for non-login shells.
# Gets evaluated in all occasion
# For fast-evaluation environment variable and code for your user-only
# and bash-only command-line usage (aliases for instance). bashism are welcome.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If running interactively
if [[ "$-" =~ .*i.* ]]; then
  # make less more friendly for non-text input files, see lesspipe(1)
  [[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

  # set variable identifying the chroot you work in (used in the prompt below)
  if [[ -z "${debian_chroot:-}" && -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
  fi

  # set a fancy prompt (non-color, unless we know we "want" color)
  if [[ "${TERM}" =~ xterm-color|*-256color ]]; then
    color_prompt=yes
  fi

  # uncomment for a colored prompt, if the terminal has the capability; turned
  # off by default to not distract the user: the focus in a terminal window
  # should be on the output of commands, not on the prompt
  force_color_prompt=yes

  if [[ -n "${force_color_prompt}" ]]; then
    if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
      # We have color support; assume it's compliant with Ecma-48
      # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
      # a case would tend to support setf rather than setaf.)
      color_prompt=yes
    else
      color_prompt=
    fi
  fi

  if [[ "${color_prompt}" = yes ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
  fi
  unset color_prompt force_color_prompt

  # If this is an xterm set the title to user@host:dir
  if [[ "${TERM}" =~ xterm*|rxvt* ]]; then
    PS1="\[\e]0;${debian_chroot:+(${debian_chroot})}\u@\h: \w\a\]${PS1}"
  fi

  if [[ -d "${HOME}/.bash-dev-env/aliases.d" ]]; then
    for i in "${HOME}/.bash-dev-env/aliases.d"/*.sh; do
      if [[ -f "${i}" ]]; then
        # shellcheck source=conf/MandatorySoftwares/.bash-dev-env/aliases.d/bash-dev-env.sh
        source "${i}"
      fi
    done
    unset i
  fi

  # enable programmable completion features (you don't need to enable
  # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
  # sources /etc/bash.bashrc).
  if ! shopt -oq posix; then
    completion_loaded=0
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
      source /usr/share/bash-completion/bash_completion
      completion_loaded=1
    elif [[ -f /etc/bash_completion ]]; then
      # sudo apt install bash-completion
      source /etc/bash_completion
      completion_loaded=1
    fi
    if [[ "${completion_loaded}" = "1" && -d "${HOME}/.bash-dev-env/completions.d" ]]; then
      for i in "${HOME}/.bash-dev-env/completions.d"/*.sh; do
        if [[ -f "${i}" ]]; then
          # shellcheck source=conf/ShellBash/.bash-dev-env/completions.d/makeTargets.sh
          source "${i}"
        fi
      done
      unset i
    fi
    unset completion_loaded
  fi

  if [[ -d "${HOME}/.bash-dev-env/interactive.d" ]]; then
    for i in "${HOME}/.bash-dev-env/interactive.d"/*.sh; do
      if [[ -f "${i}" ]]; then
        # shellcheck source=conf/ShellBash/.bash-dev-env/interactive.d/bash_navigation.sh
        source "${i}"
      fi
    done
    unset i
  fi

fi

# shellcheck disable=SC2046
eval $(ssh-agent)
if [[ -f "${HOME}/.ssh/id_rsa" ]]; then
  ssh-add "${HOME}/.ssh/id_rsa"
fi
