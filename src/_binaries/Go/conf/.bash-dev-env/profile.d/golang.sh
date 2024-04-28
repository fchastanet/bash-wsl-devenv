#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

[[ :${PATH}: =~ (^|:)${HOME}/golang/go/bin(:|$) ]] || PATH=${HOME}/golang/go/bin:${PATH}
[[ :${PATH}: =~ (^|:)${HOME}/go/bin(:|$) ]] || PATH=${HOME}/go/bin:${PATH}
