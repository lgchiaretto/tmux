#!/usr/bin/env bash

actions="1 - Create cluster\n2 - Destroy cluster\n3 - Edit install configs\n4 - Export 'kube:admin' kubeconfig\n5 - Login with 'kubeadmin' user\n6 - Start cluster\n7 - Stop cluster\n8 - List OpenShift releases available on quay.chiaret.to"

clusters() {
  local dir="$1"
  vmwarenotes=$(jq -r '.vmwarenotes' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  ocpversion=$(jq -r '.ocpversion' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  clustertype=$(jq -r '.clustertype' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  sno=$(jq -r '.sno' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  started_file="/vms/clusters/$dir/started"

  if [ -f "$started_file" ]; then
    printf "%-19s %-12s %-12s %-12s %s\n" "$dir *" "$ocpversion" "$clustertype" "$sno" "$vmwarenotes"
  else
    printf "%-19s %-12s %-12s %-12s %s\n" "$dir" "$ocpversion" "$clustertype" "$sno" "$vmwarenotes"
  fi
}

selection_list=$(find /vms/clusters/ -mindepth 1 -maxdepth 1 -type d -name '*-*' \
  ! -name 'backup-20230903' \
  ! -name '*-files' \
  ! -name 'quay-*' \
  -exec basename {} \; | while read -r dir; do
    clusters "$dir"
  done)

if [ -z "$selection_list" ]; then
    selection_list="No clusters found"
fi

selected_action=$(
    echo -e "$selection_list" | fzf-tmux \
        --header=$'--------------------------------- Help -------------------------------------\n
[1 or c]     Create cluster
[2 or d]     Destroy cluster
[3 or s]     Start cluster
[4]          Stop cluster
[5 or k]     Export kubeconfig
[6 or e]     Edit install configs
[7 or l]     List OpenShift releases available on quay.chiaret.to
[8]          Open tmuxp create session
[9 or p]     Copy kubeadmin password to clipboard
[Enter]      Login with kubeadmin user
[Esc]        Exit

------------------------------ Available Clusters ------------------------------                                       

Cluster Name        Version      Type         SNO?         Description' \
        --layout=reverse \
        -h 40 \
        -p "100%,52%" \
        --ansi \
        --sort \
        --exact \
        --bind '1,c:execute-silent(tmux send-keys "/usr/local/bin/ocpcreatecluster" C-m)+abort' \
        --bind '2,d:execute-silent(tmux send-keys "/usr/local/bin/ocpdestroycluster "{1} C-m)+abort' \
        --bind '3,s:execute-silent(tmux new-window  -n "start: "{1} "cd /vms/clusters/"{1}" && ./startvms.sh && touch started && ssh lchiaret@bastion.aap.chiaret.to \"touch /vms/clusters/{1}/started\"; bash")+abort' \
        --bind '4:execute-silent(tmux send-keys "cd /vms/clusters/"{1}"/ && ./stopvms.sh && rm -f started && ssh lchiaret@bastion.aap.chiaret.to \"rm -f /vms/clusters/{1}/started\"" C-m)+abort' \
        --bind '5,k:execute-silent(tmux new-window  -n "export: "{1} "export KUBECONFIG=/vms/clusters/{1}/auth/kubeconfig; bash")+abort' \
        --bind '6,e:execute-silent(tmux send-keys /usr/local/bin/ocpvariablesfiles C-m)+abort' \
        --bind '7,l:execute-silent(tmux send-keys /usr/local/bin/ocpreleasesonquay C-m)+abort' \
        --bind '8:execute-silent(tmux send-keys "yes | tmuxp load /vms/clusters/"{1}"/create-tmuxp.yaml" C-m)+abort' \
        --bind '9,p:execute-silent(tmux send-keys "cat /vms/clusters/"{1}"/auth/kubeadmin-password | xclip -selection clipboard -i" C-m)+abort' \
        --expect=enter
)


if [ -n "$selected_action" ]; then
  clustername=$(echo $selected_action | awk '{print $2}')
  tmux send-keys "oc login https://api.$clustername.chiaret.to:6443 -u kubeadmin -p \$(cat /vms/clusters/$clustername/auth/kubeadmin-password) --insecure-skip-tls-verify" C-m
fi

if [ $? -ne 0 ]; then
    exit 0
fi
