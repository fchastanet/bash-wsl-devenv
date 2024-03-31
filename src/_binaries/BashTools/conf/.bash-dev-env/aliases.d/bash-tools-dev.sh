#!/bin/bash

alias bats='vendor/bats/bin/bats'
alias batsP='vendor/bats/bin/bats -j 30'
alias batsX='bats -x --print-output-on-failure'
alias batsXX='bats -x --print-output-on-failure --no-tempdir-cleanup'
