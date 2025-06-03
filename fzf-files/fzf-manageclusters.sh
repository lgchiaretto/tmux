#!/usr/bin/env bash

actions="1 - Create cluster\n2 - Destroy cluster\n3 - Edit install configs\n4 - Export 'kube:admin' kubeconfig\n5 - Login with 'kubeadmin' user\n6 - Start cluster\n7 - Stop cluster\n8 - List OpenShift releases available on quay.chiaret.to"

clusters() {
  local dir="$1"
  vmwarenotes=$(jq -r '.vmwarenotes' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  ocpversion=$(jq -r '.ocpversion' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  clustertype=$(jq -r '.clustertype' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  sno=$(jq -r '.sno' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  platform=$(jq -r '.platform' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  n_worker=$(jq -r '.n_worker' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  started_file="/vms/clusters/$dir/started"

  if [ -f "$started_file" ]; then
    printf "%-19s %-12s %-6s %-10s %-14s %-12s %s\n" "$dir *" "$ocpversion" "$(echo "$clustertype" | tr '[:lower:]' '[:upper:]')" "$sno" $platform "$n_worker" "$vmwarenotes"
  else
    printf "%-19s %-12s %-6s %-10s %-14s %-12s %s\n" "$dir" "$ocpversion" "$(echo "$clustertype" | tr '[:lower:]' '[:upper:]')" "$sno" "$platform" "$n_worker" "$vmwarenotes"
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
    --header=$'
------------------ Cluster creation -------------------------------------- Cluster actions -------------------
|                                                     |                                                      |
|  [c]........Create cluster                          |    [s]........Start cluster                          |
|  [e]........Edit cluster install config files       |    [S]........Stop cluster                           |
|                                                     |    [d]........Destroy cluster                        |
|                                                     |    [U]........Upgrade cluster                        |
|------------------ OpenShift Tools ------------------|    [t]........Open tmuxp create session              |
|                                                     |    [p]........Copy kubeadmin password to clipboard   |
|  [C]........Check latest OCP Versions available     |    [k]........kubeconfig for cluster                 |
|  [u]........Show OpenShift update path              |    [f]........Enter cluster files directory          |
|  [D]........Copy or download and install OpenShift  |    [Enter]....Login with kubeadmin user              |
|             client                                  |                                                      |
|                                                     |                                                      |
|                                                     |                                                      |
|                                                     |                                                      |
|  [Esc]......Exit                                    |                                                      |
|                                                     |                                                      |
|                                                     |                                                      |
--------------------------------------------------------------------------------------------------------------
Cluster Name        Version      Type   SNO?       Platform       Workers              Description
--------------------------------------------------------------------------------------------------------------' \
    --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
    --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
    --layout=reverse \
    --border-label=" chiaret.to " \
    --border-label-pos=center \
    --border=rounded \
    -h 40 \
    -p "55%,55%" \
    --sort \
    --no-input \
    --multi \
    --bind 'c:execute-silent(tmux send-keys "/usr/local/bin/ocpcreatecluster" C-m)+abort' \
    --bind 'C:execute-silent(tmux send-keys ~/.tmux/fzf-ocpversions.sh C-m)+abort' \
    --bind 'd:execute-silent(tmux send-keys "/usr/local/bin/ocpdestroycluster "{1} C-m)+abort' \
    --bind 's:execute-silent(tmux send-keys "cd /vms/clusters/"{1}" && ./startvms.sh && touch started && ssh lchiaret@bastion.aap.chiaret.to \"touch /vms/clusters/{1}/started\"" C-m)+abort' \
    --bind 'S:execute-silent(tmux send-keys "cd /vms/clusters/"{1}" && ./stopvms.sh  && rm -f started && ssh lchiaret@bastion.aap.chiaret.to \"rm -f /vms/clusters/{1}/started\"" C-m)+abort' \
    --bind 'k:execute-silent(tmux new-window  -n "export: "{1} "export KUBECONFIG=/vms/clusters/{1}/auth/kubeconfig; bash")+abort' \
    --bind 'e:execute-silent(tmux send-keys /usr/local/bin/ocpvariablesfiles C-m)+abort' \
    --bind 'U:execute-silent(tmux send-keys "/usr/local/bin/ocpupgradecluster "{1} C-m)+abort' \
    --bind 'u:execute-silent(tmux send-keys /usr/local/bin/ocpupdate_path C-m)+abort' \
    --bind 'D:execute-silent(tmux send-keys /usr/local/bin/ocpgetclient C-m)+abort' \
    --bind 'f:execute-silent(tmux send-keys "cd /vms/clusters/"{1} C-m)+abort' \
    --bind 't:execute-silent(tmux send-keys "yes | tmuxp load /vms/clusters/"{1}"/create-tmuxp.yaml" C-m)+abort' \
    --bind 'p:execute-silent(tmux send-keys "cat /vms/clusters/"{1}"/auth/kubeadmin-password | xclip -selection clipboard -i" C-m)+abort' \
    --expect=enter 
)

if [ -n "$selected_action" ]; then
  clustername=$(echo "$selected_action" | tail -1 | awk '{print $1}')
  tmux send-keys "oc login https://api.$clustername.chiaret.to:6443 -u kubeadmin -p \$(cat /vms/clusters/$clustername/auth/kubeadmin-password) --insecure-skip-tls-verify" C-m
fi

if [ $? -ne 0 ]; then
    exit 0
fi
