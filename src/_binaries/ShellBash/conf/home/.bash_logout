#!/usr/bin/env bash
###############################################################################
# AVOID EDITING THIS FILE 
# PREFER to add files in dedicated sections of ~/.bash-dev-env
# CHECK ~/.bash-dev-env/README.md
###############################################################################

# clean history at exit by removing useless commands

# save current history
history -n

# do not store some simple commands
tempHistory=$(mktemp -p /tmp)
trap 'rm -f ${tempHistory}' EXIT
history | sort -k2 -k1nr | uniq -f1 | sort -n | cut -c8- | grep -v -E "^ls|^ll|^pwd |^ |^exit|^mc$|^su$|^df|^clear|^ps|^history|^env|^#|^vi|^exit" >"${tempHistory}"

# clear history
history -c

# load cleaned history temp file
history -r "${tempHistory}"

# write history
history -w
