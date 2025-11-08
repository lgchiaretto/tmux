#!/bin/bash

CLUSTER=$(tmux display-message -p '#S')
KUBECONFIG_PATH="/vms/clusters/${CLUSTER}/auth/kubeconfig"

if [[ -f "$KUBECONFIG_PATH" ]]; then
    OPENSHIFT_VERSION=$(KUBECONFIG=$KUBECONFIG_PATH oc version | grep Server | awk -F' ' '{print $3}')
    OPENSHIFT_PROJECT=$(KUBECONFIG=$KUBECONFIG_PATH oc project -q)
    if [[ -z "$OPENSHIFT_PROJECT" ]]; then
        OPENSHIFT_PROJECT="#[fg=red]<no-project>"
    fi  
    if [[ -z "$OPENSHIFT_VERSION" ]]; then
        echo -e "#[fg=red]N/A"
    else
        echo "#[fg=orange]${OPENSHIFT_VERSION}#[fg=white]:#[fg=green](k)#[fg=white]:#[fg=colour30]${OPENSHIFT_PROJECT}#[fg=white)"
    fi
else
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
fi

