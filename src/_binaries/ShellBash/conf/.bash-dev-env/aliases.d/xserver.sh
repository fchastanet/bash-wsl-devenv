#!/bin/bash

# shellcheck disable=SC2142
alias remoteDisplayOn=$'export DISPLAY="$(ip route show default | awk \'/default/ {print $3}\'):0.0"; export LIBGL_ALWAYS_INDIRECT=1'
alias remoteDisplayOff='export DISPLAY=":0.0"; export LIBGL_ALWAYS_INDIRECT=0'
