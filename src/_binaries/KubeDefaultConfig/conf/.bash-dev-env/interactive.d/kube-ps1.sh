#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if [[ -f /opt/kubeps1/kube-ps1.sh ]]; then
  #shellcheck source=/dev/null
  source /opt/kubeps1/kube-ps1.sh
  PS1='[\u@\h \W $(kube_ps1)]\$ '
fi
