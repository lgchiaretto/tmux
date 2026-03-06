#!/usr/bin/env bash

# Load configuration (global first, then user override)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi
source "$SCRIPT_DIR/../common/fzf-header.sh"

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
  local json="$CLUSTERS_BASE_PATH/$dir/$dir.json"

  # Skip clusters without a JSON file
  [[ ! -f "$json" ]] && return

  # Read fields; treat null/empty as "-"
  _jv() { local v; v=$(jq -r "$1 // empty" "$json" 2>/dev/null); echo "${v:--}"; }

  local ocpversion=$(_jv '.ocpversion')
  local clustertype=$(_jv '.clustertype')
  local sno=$(_jv '.sno')
  local platform=$(_jv '.platform')
  local n_worker=$(_jv '.n_worker')
  local infra=$(_jv '.infra')
  local created_at
  created_at=$(stat -c %y "$json" 2>/dev/null | cut -d' ' -f1)
  [[ -z "$created_at" ]] && created_at="-"

  clustertype=$(echo "$clustertype" | tr '[:lower:]' '[:upper:]')

  local started_file="$CLUSTERS_BASE_PATH/$dir/started"
  local name="$dir"
  [[ -f "$started_file" ]] && name="$dir *"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$name" "$ocpversion" "$clustertype" "$sno" "$platform" "$n_worker" "$created_at" "$infra"
}

# Prepend column header so column -t aligns everything together
_col_header=$'Cluster Name\tVersion\tType\tSNO\tPlatform\tWorkers\tCreated At\tInfra'
selection_list=$(
  {
    printf '%s\n' "$_col_header"
    find $CLUSTERS_BASE_PATH/ -mindepth 1 -maxdepth 1 -type d \
      ! -name 'backup-20230903' \
      ! -name 'backup*' \
      ! -name '*-files*' \
      ! -name 'quay*' \
      ! -name 'archived' \
      ! -name 'multiclusterfiles' \
      ! -name '.cache' \
      ! -name 'createcerts' \
      -exec basename {} \; | while read -r dir; do
        clusters "$dir"
      done
  } | column -t -s $'\t'
)

# Separate the aligned header from the data
_col_hdr_line=$(head -1 <<< "$selection_list")
selection_list=$(tail -n +2 <<< "$selection_list")

if [ -z "$selection_list" ]; then
    selection_list="No clusters found"
fi

_mc_header=$(fzf_header_2col \
  "Cluster actions" "OpenShift Tools" \
  "[K]........kubeconfig (nova sessão tmux, multi-select)" "[C]........Check latest OCP Versions available" \
  "[U]........Upgrade cluster" "[O]........Show OpenShift update path" \
  "[P]........Copy kubeadmin password to clipboard" "[D]........Copy or download and install OpenShift client" \
  "[T]........Tmuxp sessions" "[L]........OpenShift/Operators Lifecycle" \
  "[E]........Edit cluster JSON file with vim" "" \
  "[W]........Open Web Console" "" \
  "[Enter]....Login with kubeadmin user" "[TAB]......Select multiple clusters" \
  "[Esc]......Exit" "" \
  "" "" \
  "Type to filter clusters by name" ""
)
_mc_header+=$'\n'"$_col_hdr_line"
# Popup dimensions: width from header box OR widest data line, height from content
_mc_pw=$(fzf_header_popup_width "$_mc_header" "$selection_list")
_mc_ph=$(fzf_header_popup_height "$_mc_header" "$selection_list")

selected_action=$(
  echo -e "$selection_list" | fzf-tmux \
    --header="$_mc_header" \
    --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
    --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
    --layout=reverse \
    --border-label=" $FZF_BORDER_LABEL " \
    --border-label-pos=center \
    --border=rounded \
    -p "${_mc_pw},${_mc_ph}" \
    --sort \
    --multi \
    --bind 'K:execute-silent(for cluster in {+1}; do tmux has-session -t $cluster 2>/dev/null || tmux new-session -d -s $cluster -e KUBECONFIG="'$CLUSTERS_BASE_PATH'/$cluster/auth/kubeconfig"; tmux send-keys -t $cluster "cd '$CLUSTERS_BASE_PATH'/$cluster" C-m; done; tmux switch-client -t {1})+abort' \
    --bind 'U:execute-silent(tmux send-keys "/usr/local/bin/ocpupgradecluster "{1} C-m)+abort' \
    --bind 'P:execute-silent(tmux send-keys "cat '$CLUSTERS_BASE_PATH'/"{1}"/auth/kubeadmin-password | xclip -selection clipboard -i" C-m)+abort' \
    --bind 'T:execute-silent(tmux send-keys "/usr/local/share/tmux-ocp/fzf-files/fzf-tmuxp.sh " {1} C-m)+abort' \
    --bind 'E:execute-silent(tmux send-keys "vim '$CLUSTERS_BASE_PATH'/"{1}"/{1}.json" C-m)+abort' \
    --bind 'W:execute-silent(cluster={1}; basedomain=$(jq -r ".basedomain" "'$CLUSTERS_BASE_PATH'/$cluster/$cluster.json" 2>/dev/null); xdg-open "https://console-openshift-console.apps.$cluster.$basedomain" &)+abort' \
    --bind 'C:execute-silent(tmux send-keys /usr/local/share/tmux-ocp/fzf-files/fzf-ocpversions.sh C-m)+abort' \
    --bind 'O:execute-silent(tmux send-keys /usr/local/bin/ocpupdate_path C-m)+abort' \
    --bind 'D:execute-silent(tmux send-keys /usr/local/bin/ocpgetclient C-m)+abort' \
    --bind 'L:execute-silent(tmux send-keys /usr/local/bin/ocplifecycle C-m)+abort' \
    --expect=enter 
)

if [ -n "$selected_action" ]; then
  clustername=$(echo "$selected_action" | tail -1 | awk '{print $1}')
  basedomain=$(jq -r '.basedomain' "$CLUSTERS_BASE_PATH/$clustername/$clustername.json" 2>/dev/null || echo "No notes")
  infra=$(jq -r '.infra' "$CLUSTERS_BASE_PATH/$clustername/$clustername.json" 2>/dev/null || echo "No notes")
  
  if [[ -z "$KUBECONFIG" ]]; then
    if [ "$infra" == "kvm" ]; then
        tmux send-keys "oc login https://api.$clustername.$basedomain:6443 -u kubeadmin -p \$(cat $CLUSTERS_BASE_PATH/$clustername/auth/kubeadmin-password) --insecure-skip-tls-verify" C-m
    elif [ "$infra" == "rhdp" ]; then
        tmux send-keys "oc login https://api.$clustername.$basedomain:6443 -u admin -p \$(cat $CLUSTERS_BASE_PATH/$clustername/admin-password) --insecure-skip-tls-verify" C-m
    else
      _usr_hdr=$(fzf_header "" \
          "[Enter]     Select user to connect to cluster" \
          "[Esc]       Exit"
        )
      _usr_pw=$(fzf_header_popup_width "$_usr_hdr")
      _usr_data="$OCP_USERNAME
kubeadmin"
      _usr_ph=$(fzf_header_popup_height "$_usr_hdr" "$_usr_data")
      selected_user_raw=$(echo -e "$_usr_data" | fzf-tmux \
        --header="$_usr_hdr" \
        --layout=reverse \
        --border-label=" $FZF_BORDER_LABEL " \
        --border-label-pos=center \
        -p "${_usr_pw},${_usr_ph}" \
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
          tmux send-keys "oc login https://api.$clustername.$basedomain:6443 -u kubeadmin -p \$(cat $CLUSTERS_BASE_PATH/$clustername/auth/kubeadmin-password) --insecure-skip-tls-verify" C-m
      else
        if [ -z "$OCP_PASSWORD" ]; then
            tmux send-keys "oc login https://api.$clustername.$basedomain:6443 -u $OCP_USERNAME --insecure-skip-tls-verify" C-m
        else
            tmux send-keys "oc login https://api.$clustername.$basedomain:6443 -u $OCP_USERNAME -p \"$OCP_PASSWORD\" --insecure-skip-tls-verify" C-m
        fi
      fi
    fi
  else
    tmux display -d 5000 "KUBECONFIG is set, not logging in with kubeadmin user"
  fi
fi

if [ $? -ne 0 ]; then
    exit 0
fi

