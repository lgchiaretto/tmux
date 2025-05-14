#!/usr/bin/env bash

actions="1 - Create cluster\n2 - Destroy cluster\n3 - Edit install configs\n4 - Export 'kube:admin' kubeconfig\n5 - Login with 'kubeadmin' user\n6 - Start cluster\n7 - Stop cluster\n8 - List OpenShift releases available on quay.chiaret.to"

clusters() {
  local dir="$1"
  vmwarenotes=$(jq -r '.vmwarenotes' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  ocpversion=$(jq -r '.ocpversion' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  started_file="/vms/clusters/$dir/started"

  if [ -f "$started_file" ]; then
    printf "%-30s %-20s %-50s\n" "$dir *" "$ocpversion" "$vmwarenotes"
  else
    printf "%-30s %-20s %-50s\n" "$dir" "$ocpversion" "$vmwarenotes"
  fi
}

selection_list=$(echo '----------------------------------------------------------'; echo; echo 'Cluster Name                   OCP Version          Description' ; echo; find /vms/clusters/ -mindepth 1 -maxdepth 1 -type d -name '*-*' \
  ! -name 'backup-20230903' \
  ! -name '*-files' \
  ! -name 'quay-*' \
  -exec basename {} \; | while read -r dir; do
    clusters "$dir"
  done)
a="----------------------------------------------------------"
all_options="$actions\n\n$selection_list\n\n----------------------------------------------------------"

selected_action=$(
    echo -e "$all_options" | fzf-tmux \
        --header=$'-------------------------- Help --------------------------
[Enter]     Select the action
[Esc]       Exit
----------------------------------------------------------\n\n' \
        --layout=reverse \
        -h 40 \
        -p "100%,52%" \
        --ansi \
        --sort \
        --exact \
        --expect=enter
)

action=$(echo "$selected_action" | tail -n1)

if [ "$action" ]; then
    case "$action" in
        "7 - Stop cluster")
            /usr/local/bin/ocpstopvms
            ;;
        "6 - Start cluster")
            /usr/local/bin/ocpstartvms
            ;;
        "4 - Export 'kube:admin' kubeconfig")
            /usr/local/bin/ocpexportkubeconfig
            ;;
        "1 - Create cluster")
            /usr/local/bin/ocpcreatecluster
            ;;
        "2 - Destroy cluster")
            /usr/local/bin/ocpdestroycluster
            ;;
        "5 - Login with 'kubeadmin' user")
            /usr/local/bin/ocplogin
            ;;
        "3 - Edit install configs")
            /usr/local/bin/ocpvariablesfiles
            ;;
        "8 - List OpenShift releases available on quay.chiaret.to")
            /usr/local/bin/ocpreleasesonquay
            ;;
        "Available Clusters:")
            echo "You selected the clusters section."
            ;;
        Cluster:*)
            cluster_name=$(echo "$action" | awk '{print $2}')
            echo "You selected the cluster: $cluster_name"
            # Here you can add specific actions for a selected cluster
            ;;
        *)
            # If the selection does not match an action or the clusters header,
            # we can consider it a cluster name directly.
            # However, the formatting of the 'clusters()' output includes "Cluster:",
            # so the case above should cover the selection of a cluster.
            echo "Unknown option: $action"
            ;;
    esac
fi

if [ $? -ne 0 ]; then
    exit 0
fi
