#!/bin/bash -x

oc project -q 2>&1
OPENSHIFT_CONNECTED=$?
if [[ $OPENSHIFT_CONNECTED == 1 ]]; then
  echo "#[fg=red]N/A"
else
  OPENSHIFT_TMUX_PROJECT="$(oc project -q)"
  echo "$OPENSHIFT_TMUX_PROJECT"
fi
