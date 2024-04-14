# Zsh

## configuration files

[Source](https://thevaluable.dev/zsh-install-configure-mouseless/)

Zsh read these files in the following order:

- .zshenv - Should only contain user’s environment variables.
- .zprofile - Can be used to execute commands just after logging in.
- .zshrc - Should be used for the shell configuration and for executing
  commands.
- .zlogin - Same purpose than .zprofile, but read just after .zshrc.
- .zlogout - Can be used to execute commands when a shell exit.
