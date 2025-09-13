#!/usr/bin/env bash

actions=$(
  cat <<EOF
1 - Create cluster
2 - Destroy cluster
3 - Edit install configs
4 - Export 'kube:admin' kubeconfig
5 - Login with 'kubeadmin' user
6 - Start cluster
7 - Stop cluster
8 - List OpenShift releases available on quay.chiaret.to
9 - Run OC Mirror operations
EOF
)

clusters() {
  local dir="$1"
  vmwarenotes=$(jq -r '.vmwarenotes' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  ocpversion=$(jq -r '.ocpversion' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  clustertype=$(jq -r '.clustertype' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  sno=$(jq -r '.sno' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  vmwaredatastore=$(jq -r '.vmwaredatastore' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  vmwaredatastoreworkers=$(jq -r '.vmwaredatastoreworkers' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  vmwaredatastoreodf=$(jq -r '.vmwaredatastoreodf' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  platform=$(jq -r '.platform' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  n_worker=$(jq -r '.n_worker' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  vmwarenetwork=$(jq -r '.vmwarenetwork' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")
  created_at=$(stat -c %y /vms/clusters/$dir/$dir.json | cut -d' ' -f1)
  started_file="/vms/clusters/$dir/started"
  basedomain=$(jq -r '.basedomain' "/vms/clusters/$dir/$dir.json" 2>/dev/null || echo "No notes")

  if [ -f "$started_file" ]; then
    if [ "$vmwaredatastore" == "$vmwaredatastoreodf" ]; then
        printf "%-15s %-8s %-7s %-6s %-10s %-8s %-10s %-12s %-8s %s\n" "$dir *" "$ocpversion" "$(echo "$clustertype" | tr '[:lower:]' '[:upper:]')" "$sno" "$platform" "$n_worker" "$vmwaredatastore" "$created_at" "$vmwarenetwork" "$vmwarenotes"
    else
        printf "%-15s %-8s %-7s %-6s %-10s %-8s %-10s %-12s %-8s %s\n" "$dir *" "$ocpversion" "$(echo "$clustertype" | tr '[:lower:]' '[:upper:]')" "$sno" "$platform" "$n_worker" "$vmwaredatastore,$vmwaredatastoreodf" "$created_at" "$vmwarenetwork" "$vmwarenotes"
    fi
  else
    if [ "$vmwaredatastore" == "$vmwaredatastoreodf" ]; then
        printf "%-15s %-8s %-7s %-6s %-10s %-8s %-10s %-12s %-8s %s\n" "$dir" "$ocpversion" "$(echo "$clustertype" | tr '[:lower:]' '[:upper:]')" "$sno" "$platform" "$n_worker" "$vmwaredatastore" "$created_at" "$vmwarenetwork" "$vmwarenotes"
    else
        printf "%-15s %-8s %-7s %-6s %-10s %-8s %-10s %-12s %-8s %s\n" "$dir" "$ocpversion" "$(echo "$clustertype" | tr '[:lower:]' '[:upper:]')" "$sno" "$platform" "$n_worker" "$vmwaredatastore,$vmwaredatastoreodf" "$created_at" "$vmwarenetwork" "$vmwarenotes"
    fi
  fi
}

selection_list=$(find /vms/clusters/ -mindepth 1 -maxdepth 1 -type d \
  ! -name 'backup-20230903' \
  ! -name 'backup*' \
  ! -name '*-files' \
  ! -name 'quay*' \
  ! -name 'archived' \
  ! -name 'multiclusterfiles' \
  ! -name '.cache' \
  ! -name 'createcerts' \
  -exec basename {} \; | while read -r dir; do
    clusters "$dir"
  done)

if [ -z "$selection_list" ]; then
    selection_list="No clusters found"
fi

selected_action=$(
  echo -e "$selection_list" | fzf-tmux \
    --header=$'------------------ Cluster creation -------------------------------------- Cluster actions -------------------
|                                                     |                                                      |
|  [c]........Create cluster                          |    [s]........Start cluster                          |
|  [e]........Edit cluster install config files       |    [S]........Stop cluster                           |
|  [E]........Edit cluster JSON file with vim         |    [d]........Destroy cluster                        |
|                                                     |    [U]........Upgrade cluster                        |
|------------------ OpenShift Tools ------------------|    [t]........Tmuxp sessions                         |
|                                                     |    [p]........Copy kubeadmin password to clipboard   |
|  [C]........Check latest OCP Versions available     |    [k]........kubeconfig for cluster                 |
|  [u]........Show OpenShift update path              |    [f]........Enter cluster files directory          |
|  [D]........Copy or download and install OpenShift  |    [r]........Recreate cluster                       |
|             client                                  |    [m]........Run OC Mirror operations               |
|  [l]........OpenShift/Operators Lifecycle           |    [Enter]....Login with kubeadmin user              |
|                                                     |                                                      |
|  [Esc]......Exit                                    |                                                      |
|                                                     |                                                      |
--------------------------------------------------------------------------------------------------------------
Cluster Name    Version  Type    SNO?   Platform   Workers  Datastore  Created At   vlan     Description
--------------------------------------------------------------------------------------------------------------' \
    --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
    --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
    --layout=reverse \
    --border-label=" chiarettolabs.com.br " \
    --border-label-pos=center \
    --border=rounded \
    -h 40 \
    -p "55%,50%" \
    --sort \
    --no-input \
    --multi \
    --bind 'c:execute-silent(tmux send-keys "/usr/local/bin/ocpcreatecluster" C-m)+abort' \
    --bind 'C:execute-silent(tmux send-keys ~/.tmux/fzf-ocpversions.sh C-m)+abort' \
    --bind 'd:execute-silent(tmux send-keys "/usr/local/bin/ocpdestroycluster "{1} C-m)+abort' \
    --bind 's:execute-silent(tmux send-keys "cd /vms/clusters/"{1}" && ./startvms.sh && touch started && ssh lchiaret@bastion.aap.chiaret.to \"touch /vms/clusters/{1}/started\"" C-m)+abort' \
    --bind 'S:execute-silent(tmux send-keys "cd /vms/clusters/"{1}" && ./stopvms.sh  && rm -f started && ssh lchiaret@bastion.aap.chiaret.to \"rm -f /vms/clusters/{1}/started\"" C-m)+abort' \
    --bind 'k:execute-silent(tmux has-session -t {1} 2>/dev/null || tmux new-session -d -s {1} -e KUBECONFIG="/vms/clusters/"{1}"/auth/kubeconfig"; tmux switch-client -t {1}; tmux send-keys "cd /vms/clusters/"{1} C-m; bash)+abort' \
    --bind 'e:execute-silent(tmux send-keys /usr/local/bin/ocpvariablesfiles C-m)+abort' \
    --bind 'E:execute-silent(tmux send-keys "vim /vms/clusters/"{1}"/{1}.json" C-m)+abort' \
    --bind 'U:execute-silent(tmux send-keys "/usr/local/bin/ocpupgradecluster "{1} C-m)+abort' \
    --bind 'u:execute-silent(tmux send-keys /usr/local/bin/ocpupdate_path C-m)+abort' \
    --bind 'D:execute-silent(tmux send-keys /usr/local/bin/ocpgetclient C-m)+abort' \
    --bind 'f:execute-silent(tmux send-keys "cd /vms/clusters/"{1} C-m)+abort' \
    --bind 't:execute-silent(tmux send-keys "~/.tmux/fzf-tmuxp.sh " {1} C-m)+abort' \
    --bind 'p:execute-silent(tmux send-keys "cat /vms/clusters/"{1}"/auth/kubeadmin-password | xclip -selection clipboard -i" C-m)+abort' \
    --bind 'l:execute-silent(tmux send-keys /usr/local/bin/ocplifecycle C-m)+abort' \
    --bind 'r:execute-silent(tmux send-keys "/usr/local/bin/ocprecreatecluster "{1} C-m)+abort' \
    --bind 'm:execute-silent(tmux has-session -t oc-mirror-session 2>/dev/null || tmux new-session -d -s oc-mirror-session; tmux switch-client -t oc-mirror-session; tmux send-keys "ocp-oc-mirror.sh" C-m)+abort' \
    --expect=enter 
)

if [ -n "$selected_action" ]; then
  clustername=$(echo "$selected_action" | tail -1 | awk '{print $1}')
  basedomain=$(jq -r '.basedomain' "/vms/clusters/$clustername/$clustername.json" 2>/dev/null || echo "chiarettolabs.com.br")
  if [[ -z "$KUBECONFIG" ]]; then
      selected_user_raw=$(echo -e "chiaretto\nkubeadmin" | fzf-tmux \
        --header=$'----------------------------------------------------------------- Help -----------------------------------------------------------------
[Enter]     Select user to connect to cluster
[Esc]       Exit
----------------------------------------------------------------------------------------------------------------------------------------\n\n' \
        --layout=reverse \
        --border-label=" chiarettolabs.com.br " \
        --border-label-pos=center \
        -h 40 \
        -p "100%,50%" \
        --exact \
        --with-nth=1,2 \
        --ansi \
        --wrap \
        --expect=enter \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
      )
      selected_user=$(echo "$selected_user_raw" | tail -1)
    if [ -z "$selected_user" ]; then
        exit 0
    elif [ "$selected_user" == "kubeadmin" ]; then
        tmux send-keys "oc login https://api.$clustername.$basedomain:6443 -u kubeadmin -p \$(cat /vms/clusters/$clustername/auth/kubeadmin-password) --insecure-skip-tls-verify" C-m
    elif [ "$selected_user" == "chiaretto" ]; then
        tmux send-keys "oc login https://api.$clustername.$basedomain:6443 -u chiaretto -p \"JJ4Q0QihDH4*4O>\" --insecure-skip-tls-verify" C-m
    fi
  else
    tmux display -d 5000 "KUBECONFIG is set, not logging in with kubeadmin user"
  fi
fi

if [ $? -ne 0 ]; then
    exit 0
fi
