#!/bin/bash

oc whoami > /tmp/dummy-file-tmux

OPENSHIFT_CONNECTED=$?
if [[ $OPENSHIFT_CONNECTED -eq 1 ]]; then
  echo -e "#[fg=red, bg=colour237]N/A"
else
  OPENSHIFT_CLUSTER=$(oc whoami --show-server| awk -F '.' '{ print $2 }')
  OPENSHIFT_USER=$(oc whoami)
  OPENSHIFT_PROJECT=$(oc project -q)
  OPENSHIFT_VERSION=$(oc version | grep Server | awk -F' ' '{print $3}')
  #echo "$OPENSHIFT_CLUSTER(#[fg=white]${OPENSHIFT_VERSION}:${OPENSHIFT_USER}:${OPENSHIFT_PROJECT}#[fg=colour142, bg=colour237])"
  echo "$OPENSHIFT_CLUSTER(#[fg=orange]${OPENSHIFT_VERSION}#[fg=white]:#[fg=colour142, bg=colour237]${OPENSHIFT_USER}#[fg=white]:#[fg=orange]${OPENSHIFT_PROJECT}#[fg=colour142, bg=colour237])"
fi
