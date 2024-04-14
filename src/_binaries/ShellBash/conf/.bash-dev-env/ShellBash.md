# Bash

<https://phoenixnap.com/kb/bashrc-vs-bash-profile>

## Definition

### Login/Non-Login shell

Bash executes different startup files depending on whether the shell is a login
or non-login shell. To check the current shell type, use the shopt command:

```bash
shopt -q login_shell && echo 'Login shell' || echo 'Non-login shell'
```

The output prints Login shell if the user:

Logs in from the terminal remotely (for example, via SSH). Logs in from the
terminal locally (for example, using the login command). Launches Bash with the
-l option (bash -l).

### Interactive/Non interactive

When script is executed, the script is normally non interactive. If it is
sourced in a login shell, the script becomes interactive.

```bash
[[ $- == *i* ]] && echo Interactive || echo Non-interactive
```

### Execution condition

~/.bashrc: executed by bash(1) for non-login shells. ~/.profile: executed by the
command interpreter for login shells.

~/.profile is not executed if ~/.bash_login or ~/.bash_profile is present Most
Linux distributions have the .profile configuration file set up because it's
read by any shell type, including Bash.

## Difference between .bashrc and .bash_profile ?

The critical differences between .bashrc and .bash_profile are:

- .bashrc defines the settings for a user when running a sub-shell. Add custom
  configurations to this file to make parameters available in sub-shells for a
  specific user.
- .profile defines the settings for a user when running a login shell. Add
  custom configurations to this file to make parameters available to a specific
  user when running a login shell.

Typically all the aliases, completions will be loaded through .bashrc

## Bash-dev-env

### ~/.bash-dev-env directory structure

- `~/`

  - `~/.profile` : loads all the files

    - `~/.bash-dev-env/profile.d` : mainly environment variables

  - `~/.bashrc` : loads all the following files (if in interactive mode)

    - `~/.bash-dev-env/aliases.d` : bash aliases
    - `~/.bash-dev-env/completions.d` : bash completions
    - `~/.bash-dev-env/interactive.d` : These scripts load keybindings or
      prompts.

  - `~/.bash-dev-env/`:
    - `profile.d/` : contains all the script files that will load env variable
      related to specific products (Eg: load paths, ...)
    - `aliases.d/` : contains all the aliases
    - `completions.d/` : bash completions
    - `interactive.d/` : These scripts load keybindings or prompts.
    - `GitDefaultConfig/`
      - .gitconfig
      - .gitignore

Rules:

- Each directory can be overridden in `conf.override/<profile>/.bash-dev-env`
- Each file installed from `conf/**/.bash-dev-env` will be copied as read only
- (Later) `conf.override/**/.remove` allows to list files not needed
- (Later) All the files will be sourced and concatenated to one cache file
  (could use bash-tpl)
  - Cache will be invalidated based on find last modified file.
