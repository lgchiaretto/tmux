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

selection_list=$(find /vms/clusters/ -mindepth 1 -maxdepth 1 -type d -name '*-*' \
  ! -name 'backup-20230903' \
  ! -name '*-files' \
  ! -name 'quay-*' \
  -exec basename {} \; | while read -r dir; do
    clusters "$dir"
  done)
all_options="$selection_list"

selected_action=$(
    echo -e "$all_options" | fzf-tmux \
        --header=$'----------------------------- Help -----------------------------
[1]     Create cluster
[2]     Destroy cluster
[3]     Start cluster
[4]     Stop cluster
[5]     Export kubeconfig
[6]     Login with kubeadmin user
[7]     Edit install configs
[8]     List OpenShift releases available on quay.chiaret.to
[Esc]       Exit
----------------------------------------------------------------\n
Cluster Name                   OCP Version          Description\n\n' \
        --layout=reverse \
        -h 40 \
        -p "100%,52%" \
        --ansi \
        --sort \
        --exact \
        --bind '1:execute-silent(tmux send-keys "/usr/local/bin/ocpcreatecluster" C-m)+abort' \
        --bind '2:execute-silent(tmux send-keys "/usr/local/bin/ocpdestroycluster "{1} C-m)+abort' \
        --bind '3:execute-silent(tmux send-keys "cd /vms/clusters/"{1}" && ./startvms.sh && touch started" C-m)+abort' \
        --bind '4:execute-silent(tmux send-keys "cd /vms/clusters/"{1}" && ./stopvms.sh && rm -f started" C-m)+abort' \
        --bind '5:execute-silent(tmux new-window  -n "export: {1}" "export KUBECONFIG=/vms/clusters/{1}/auth/kubeconfig; bash")+abort' \
        --bind '6:execute-silent(tmux send-keys "oc login https://api.{1}.chiaret.to:6443 -u kubeadmin -p \$(cat /vms/clusters/{1}/auth/kubeadmin-password) --insecure-skip-tls-verify;bash")+abort' \
        --bind '7:execute-silent(tmux send-keys /usr/local/bin/ocpvariablesfiles C-m)+abort' \
        --bind '8:execute-silent(tmux send-keys /usr/local/bin/ocpreleasesonquay C-m)+abort' \
        --expect=enter
)

if [ $? -ne 0 ]; then
    exit 0
fi
