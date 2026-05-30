#!/usr/bin/env bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi
source "$SCRIPT_DIR/../common/fzf-header.sh"

# ── Cache configuration ──────────────────────────────────────
_cache_dir="${OCP_CACHE_DIR:-${CLUSTERS_BASE_PATH:+$CLUSTERS_BASE_PATH/.cache}}"
_cache_dir="${_cache_dir:-/tmp}"
mkdir -p "$_cache_dir" 2>/dev/null
_cache_lookup="$_cache_dir/mc-lookup.cache"
_cache_display="$_cache_dir/mc-display.cache"
_cache_ttl="${MC_CACHE_TTL:-300}"  # seconds (default 5 min)

# ── Cache scan logic (extracted so it can run standalone for bg refresh) ──
_do_scan() {
  local lkp_file="$1" dsp_file="$2"
  > "$lkp_file"
  > "$dsp_file"

  # Local clusters (flat: CLUSTERS_BASE_PATH/cluster/)
  if [[ -n "$CLUSTERS_BASE_PATH" && -d "$CLUSTERS_BASE_PATH" ]]; then
    while read -r dir; do
      [[ -z "$dir" ]] && continue
      json="$CLUSTERS_BASE_PATH/$dir/$dir.json"
      [[ ! -f "$json" ]] && continue

      _jv() { local v; v=$(jq -r "$1 // empty" "$json" 2>/dev/null); echo "${v:--}"; }

      ocpversion=$(_jv '.ocpversion')
      clustertype=$(_jv '.clustertype' | tr '[:lower:]' '[:upper:]')
      sno=$(_jv '.sno')
      platform=$(_jv '.platform')
      n_worker=$(_jv '.n_worker')
      infra=$(_jv '.infra')
      owner_username=$(_jv '.owner_username')
      basedomain=$(_jv '.basedomain')
      created_at=$(stat -c %y "$json" 2>/dev/null | cut -d' ' -f1)
      [[ -z "$created_at" ]] && created_at="-"

      name="$dir"
      [[ -f "$CLUSTERS_BASE_PATH/$dir/started" ]] && name="$dir *"

      echo "${dir}|LOCAL||${CLUSTERS_BASE_PATH}/${dir}|${basedomain}|${infra}" >> "$lkp_file"
      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$name" "LOCAL" "$ocpversion" "$clustertype" "$sno" "$platform" "$n_worker" "$created_at" "$infra" "$owner_username" >> "$dsp_file"
    done < <(find "$CLUSTERS_BASE_PATH/" -mindepth 1 -maxdepth 1 -type d \
        ! -name 'backup*' ! -name '*-files*' ! -name 'quay*' ! -name 'archived' \
        ! -name 'multiclusterfiles' ! -name '.cache' ! -name 'createcerts' \
        ! -name 'isos' ! -name 'variables-files*' ! -name 'dockerconfig-*' ! -name 'rtm' \
        -exec basename {} \;)
  fi

  # Managed clusters (nested: basepath/owner/cluster/)
  if [[ -n "$CLUSTERS_MANAGED_PATHS" ]]; then
    for entry in $CLUSTERS_MANAGED_PATHS; do
      IFS=':' read -r label host path <<< "$entry"
      [[ -z "$label" || -z "$path" ]] && continue

      if [[ -z "$host" ]]; then
        # Local nested directory
        _managed_out=$(_scan_nested_local "$path" "$label")
      else
        # Remote via SSH
        _managed_out=$(ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" bash -s -- "$path" "$label" 2>/dev/null <<'REMOTESCRIPT'
base="$1"; label="$2"
[[ ! -d "$base" ]] && exit 0
for owner_dir in "$base"/*/; do
  [[ ! -d "$owner_dir" ]] && continue
  for cluster_dir in "$owner_dir"/*/; do
    [[ ! -d "$cluster_dir" ]] && continue
    dir=$(basename "$cluster_dir")
    json="$cluster_dir/$dir.json"
    [[ ! -f "$json" ]] && continue

    _jv() { local v; v=$(jq -r "$1 // empty" "$json" 2>/dev/null); echo "${v:--}"; }

    ocpversion=$(_jv '.ocpversion')
    clustertype=$(_jv '.clustertype' | tr '[:lower:]' '[:upper:]')
    sno=$(_jv '.sno')
    platform=$(_jv '.platform')
    n_worker=$(_jv '.n_worker')
    infra=$(_jv '.infra')
    owner_username=$(_jv '.owner_username')
    basedomain=$(_jv '.basedomain')
    created_at=$(stat -c %y "$json" 2>/dev/null | cut -d' ' -f1)
    [[ -z "$created_at" ]] && created_at="-"

    name="$dir"
    [[ -f "$cluster_dir/started" ]] && name="$dir *"

    echo "LKP:${dir}|${cluster_dir%/}|${basedomain}|${infra}"
    printf 'DSP:%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$name" "$label" "$ocpversion" "$clustertype" "$sno" "$platform" "$n_worker" "$created_at" "$infra" "$owner_username"
  done
done
REMOTESCRIPT
        )
      fi

      while IFS= read -r line; do
        case "$line" in
          LKP:*)
            data="${line#LKP:}"
            cname="${data%%|*}"
            rest="${data#*|}"
            echo "${cname}|${label}|${host}|${rest}" >> "$lkp_file"
            ;;
          DSP:*)
            echo "${line#DSP:}" >> "$dsp_file"
            ;;
        esac
      done <<< "$_managed_out"
    done
  fi
}

_scan_nested_local() {
  local base="$1" label="$2"
  [[ ! -d "$base" ]] && return
  for owner_dir in "$base"/*/; do
    [[ ! -d "$owner_dir" ]] && continue
    for cluster_dir in "$owner_dir"/*/; do
      [[ ! -d "$cluster_dir" ]] && continue
      dir=$(basename "$cluster_dir")
      json="$cluster_dir/$dir.json"
      [[ ! -f "$json" ]] && continue

      _jv() { local v; v=$(jq -r "$1 // empty" "$json" 2>/dev/null); echo "${v:--}"; }

      ocpversion=$(_jv '.ocpversion')
      clustertype=$(_jv '.clustertype' | tr '[:lower:]' '[:upper:]')
      sno=$(_jv '.sno')
      platform=$(_jv '.platform')
      n_worker=$(_jv '.n_worker')
      infra=$(_jv '.infra')
      owner_username=$(_jv '.owner_username')
      basedomain=$(_jv '.basedomain')
      created_at=$(stat -c %y "$json" 2>/dev/null | cut -d' ' -f1)
      [[ -z "$created_at" ]] && created_at="-"

      name="$dir"
      [[ -f "$cluster_dir/started" ]] && name="$dir *"

      echo "LKP:${dir}|${cluster_dir%/}|${basedomain}|${infra}"
      printf 'DSP:%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$name" "$label" "$ocpversion" "$clustertype" "$sno" "$platform" "$n_worker" "$created_at" "$infra" "$owner_username"
    done
  done
}

# ── Handle --refresh flag (used for background refresh) ──────
if [[ "$1" == "--refresh" ]]; then
  _do_scan "$_cache_lookup" "$_cache_display"
  exit 0
fi

# ── Load from cache or scan ──────────────────────────────────
_cache_fresh=false
if [[ -f "$_cache_lookup" && -f "$_cache_display" ]]; then
  _age=$(( $(date +%s) - $(stat -c %Y "$_cache_lookup") ))
  if (( _age < _cache_ttl )); then
    _cache_fresh=true
  fi
fi

_lookup=$(mktemp /tmp/tmux-mc-lkp.XXXXXX)
_display=$(mktemp /tmp/tmux-mc-dsp.XXXXXX)
_helper=$(mktemp /tmp/tmux-mc-hlp.XXXXXX)
trap 'rm -f "$_lookup" "$_display" "$_helper"' EXIT

cat > "$_helper" <<'HELPEREOF'
mc_resolve() {
  local c="${1% \*}" f="$2" line
  line=$(grep "^${c}|" "$f" | head -1)
  MC_ENV=$(echo "$line" | cut -d'|' -f2)
  MC_HOST=$(echo "$line" | cut -d'|' -f3)
  MC_PATH=$(echo "$line" | cut -d'|' -f4)
  MC_BASEDOMAIN=$(echo "$line" | cut -d'|' -f5)
  MC_INFRA=$(echo "$line" | cut -d'|' -f6)
}
HELPEREOF

if $_cache_fresh; then
  cp "$_cache_lookup" "$_lookup"
  cp "$_cache_display" "$_display"
else
  _do_scan "$_lookup" "$_display"
  cp "$_lookup" "$_cache_lookup"
  cp "$_display" "$_cache_display"
fi

# ── Trigger background refresh for next invocation ───────────
if $_cache_fresh; then
  (nohup bash "$0" --refresh >/dev/null 2>&1 &)
fi

# ── Build selection list ─────────────────────────────────────
_col_header=$'Cluster Name\tEnv\tVersion\tType\tSNO\tPlatform\tWorkers\tCreated At\tInfra\tOwner'

selection_list=$(
  {
    printf '%s\n' "$_col_header"
    cat "$_display"
  } | column -t -s $'\t'
)

_col_hdr_line=$(head -1 <<< "$selection_list")
selection_list=$(tail -n +2 <<< "$selection_list")

if [ -z "$selection_list" ]; then
    selection_list="No clusters found"
fi

# ── FZF header ───────────────────────────────────────────────
_mc_header=$(fzf_header_2col \
  "Cluster actions" "OpenShift Tools" \
  "[K]........kubeconfig (nova sessão tmux, multi-select)" "[C]........Check latest OCP Versions available" \
  "[U]........Upgrade cluster" "[O]........Show OpenShift update path" \
  "[P]........Copy kubeadmin password to clipboard" "[D]........Copy or download and install OpenShift client" \
  "[T]........Tmuxp sessions" "[L]........OpenShift/Operators Lifecycle" \
  "[E]........Edit cluster JSON file with vim" "" \
  "[W]........Open Web Console" "" \
  "[Enter]....Login with kubeadmin user" "[TAB]......Select multiple clusters" \
  "[Esc]......Exit" "[Ctrl-R]...Refresh cluster list" \
  "" "" \
  "Type to filter clusters by name" ""
)
_mc_header+=$'\n'"$_col_hdr_line"
_mc_pw=$(fzf_header_popup_width "$_mc_header" "$selection_list")
_mc_ph=$(fzf_header_popup_height "$_mc_header" "$selection_list")

# ── FZF ──────────────────────────────────────────────────────
selected_action=$(
  echo "$selection_list" | fzf-tmux \
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
    --bind "ctrl-r:execute-silent(bash '$0' --refresh)+abort" \
    --bind "K:execute-silent(
      source '$_helper'
      for cluster in {+1}; do
        cluster=\"\${cluster% \\*}\"
        mc_resolve \"\$cluster\" '$_lookup'
        if [[ -z \"\$MC_HOST\" ]]; then
          tmux has-session -t \$cluster 2>/dev/null || tmux new-session -d -s \$cluster -e KUBECONFIG=\"\$MC_PATH/auth/kubeconfig\"
          tmux send-keys -t \$cluster \"cd \$MC_PATH\" C-m
        else
          tmux has-session -t \$cluster 2>/dev/null || tmux new-session -d -s \$cluster
          tmux send-keys -t \$cluster \"ssh \$MC_HOST -t 'export KUBECONFIG=\$MC_PATH/auth/kubeconfig; cd \$MC_PATH; bash -l'\" C-m
        fi
      done
      tmux switch-client -t {1}
    )+abort" \
    --bind "U:execute-silent(
      source '$_helper'
      cluster='{1}'; cluster=\"\${cluster% \\*}\"
      mc_resolve \"\$cluster\" '$_lookup'
      tmux send-keys \"/usr/local/bin/ocpupgradecluster \$cluster \$MC_PATH\" C-m
    )+abort" \
    --bind "P:execute-silent(
      source '$_helper'
      cluster='{1}'; cluster=\"\${cluster% \\*}\"
      mc_resolve \"\$cluster\" '$_lookup'
      if [[ -z \"\$MC_HOST\" ]]; then
        tmux send-keys \"cat \$MC_PATH/auth/kubeadmin-password | xclip -selection clipboard -i\" C-m
      else
        pw=\$(ssh -o ConnectTimeout=3 \"\$MC_HOST\" \"cat \$MC_PATH/auth/kubeadmin-password\" 2>/dev/null)
        echo -n \"\$pw\" | xclip -selection clipboard -i
        tmux display -d 2000 \"Password copied to clipboard\"
      fi
    )+abort" \
    --bind "T:execute-silent(
      source '$_helper'
      cluster='{1}'; cluster=\"\${cluster% \\*}\"
      mc_resolve \"\$cluster\" '$_lookup'
      tmux send-keys \"/usr/local/share/tmux-ocp/fzf-files/fzf-tmuxp.sh \$cluster \$MC_PATH\" C-m
    )+abort" \
    --bind "E:execute-silent(
      source '$_helper'
      cluster='{1}'; cluster=\"\${cluster% \\*}\"
      mc_resolve \"\$cluster\" '$_lookup'
      if [[ -z \"\$MC_HOST\" ]]; then
        tmux send-keys \"vim \$MC_PATH/\$cluster.json\" C-m
      else
        tmux send-keys \"ssh \$MC_HOST -t vim \$MC_PATH/\$cluster.json\" C-m
      fi
    )+abort" \
    --bind "W:execute-silent(
      source '$_helper'
      cluster='{1}'; cluster=\"\${cluster% \\*}\"
      mc_resolve \"\$cluster\" '$_lookup'
      xdg-open \"https://console-openshift-console.apps.\$cluster.\$MC_BASEDOMAIN\" &
    )+abort" \
    --bind "C:execute-silent(tmux send-keys /usr/local/share/tmux-ocp/fzf-files/fzf-ocpversions.sh C-m)+abort" \
    --bind "O:execute-silent(tmux send-keys /usr/local/bin/ocpupdate_path C-m)+abort" \
    --bind "D:execute-silent(tmux send-keys /usr/local/bin/ocpgetclient C-m)+abort" \
    --bind "L:execute-silent(tmux send-keys /usr/local/bin/ocplifecycle C-m)+abort" \
    --expect=enter
)

# ── Handle Enter: login to cluster ───────────────────────────
if [ -n "$selected_action" ]; then
  clustername=$(echo "$selected_action" | tail -1 | awk '{print $1}')
  clustername="${clustername% \*}"

  source "$_helper"
  mc_resolve "$clustername" "$_lookup"

  if [[ -z "$KUBECONFIG" ]]; then
    if [[ -n "$MC_HOST" ]]; then
      # Remote cluster
      _pw=$(ssh -o ConnectTimeout=3 "$MC_HOST" "cat '$MC_PATH/auth/kubeadmin-password'" 2>/dev/null)
      tmux send-keys "oc login https://api.$clustername.$MC_BASEDOMAIN:6443 -u kubeadmin -p '$_pw' --insecure-skip-tls-verify" C-m
    elif [ "$MC_INFRA" == "kvm" ]; then
      tmux send-keys "oc login https://api.$clustername.$MC_BASEDOMAIN:6443 -u kubeadmin -p \$(cat $MC_PATH/auth/kubeadmin-password) --insecure-skip-tls-verify" C-m
    elif [ "$MC_INFRA" == "rhdp" ]; then
      tmux send-keys "oc login https://api.$clustername.$MC_BASEDOMAIN:6443 -u admin -p \$(cat $MC_PATH/admin-password) --insecure-skip-tls-verify" C-m
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
          tmux send-keys "oc login https://api.$clustername.$MC_BASEDOMAIN:6443 -u kubeadmin -p \$(cat $MC_PATH/auth/kubeadmin-password) --insecure-skip-tls-verify" C-m
      else
        if [ -z "$OCP_PASSWORD" ]; then
            tmux send-keys "oc login https://api.$clustername.$MC_BASEDOMAIN:6443 -u $OCP_USERNAME --insecure-skip-tls-verify" C-m
        else
            tmux send-keys "oc login https://api.$clustername.$MC_BASEDOMAIN:6443 -u $OCP_USERNAME -p \"$OCP_PASSWORD\" --insecure-skip-tls-verify" C-m
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
