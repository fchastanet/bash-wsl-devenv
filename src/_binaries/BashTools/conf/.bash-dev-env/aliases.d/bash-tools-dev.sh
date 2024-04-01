#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

alias bats='vendor/bats/bin/bats'
alias batsP='vendor/bats/bin/bats -j 30'
alias batsX='bats -x --print-output-on-failure'
alias batsXX='bats -x --print-output-on-failure --no-tempdir-cleanup'
