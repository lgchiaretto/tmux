#!/usr/bin/env bash

oc whoami > /tmp/dummy-file-tmux

OPENSHIFT_CONNECTED=$?
if [[ $OPENSHIFT_CONNECTED -eq 1 ]]; then
  echo -e "#[fg=red]N/A"
else
  OPENSHIFT_CLUSTER=$(oc whoami --show-server| awk -F '.' '{ print $2 }')
  OPENSHIFT_USER=$(oc whoami)
  OPENSHIFT_PROJECT=$(oc project -q)

  if [[ $OPENSHIFT_PROJECT == "" ]]; then
    OPENSHIFT_PROJECT="#[fg=red]<deleted>"
  fi

  OPENSHIFT_VERSION=$(oc version | grep Server | awk -F' ' '{print $3}')
  #echo "$OPENSHIFT_CLUSTER(#[fg=white]${OPENSHIFT_VERSION}:${OPENSHIFT_USER}:${OPENSHIFT_PROJECT}#[fg=colour142, bg=colour237])"
  echo "$OPENSHIFT_CLUSTER(#[fg=orange]${OPENSHIFT_VERSION}#[fg=white]:#[fg=colour142]${OPENSHIFT_USER}#[fg=white]:#[fg=colour30]${OPENSHIFT_PROJECT}#[fg=white)"
fi
