#!/usr/bin/env bash

# Load configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../common" && pwd)/fzf-header.sh"

project_name=$(oc project -q)

if [ -z "$project_name" -a $? -eq 0 ]; then
    tmux display -d 5000 'No project found'
    exit 0
elif [ -z "$project_name" -a $? -eq 1 ]; then
    tmux display -d 5000 'No project found. Are you connected on any OpenShift cluster?'
    exit 0
fi

_hdr=$(fzf_header "" \
  "[Enter]     Show pod(s) logs" \
  "[Tab]       Select pod to show log" \
  "[Esc]       Exit"
)
_allpod_data=$(oc get pods -A --field-selector=status.phase=Running --no-headers -o jsonpath="{range .items[*]}{.metadata.namespace}{'\t'}{.metadata.name}{'\n'}{end}" | column -t -s $'\t')
_pw=$(fzf_header_popup_width "$_hdr" "$_allpod_data")
_ph=$(fzf_header_popup_height "$_hdr" "$_allpod_data")
mapfile -t selected_pods_and_namespaces < <(
    echo "$_allpod_data" |
        fzf-tmux \
        --header="$_hdr" \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
        --multi \
        --layout=reverse \
        --border-label=" $FZF_BORDER_LABEL " \
        --border-label-pos=center \
        -p "${_pw},${_ph}" \
        --exact \
        | awk '{print $1 " " $2}'
)

[[ ${#selected_pods_and_namespaces[@]} -eq 0 ]] && exit

declare -A namespace_map
for line in "${selected_pods_and_namespaces[@]}"; do
    namespace=$(echo "$line" | awk '{print $1}')
    namespace_map["$namespace"]=1
done

session_name="logs"

if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name"
    tmux rename-window -t "$session_name:0" "DELETEME"
fi

first_container=""
window_created=false

processed_namespaces=()

declare -A deployment_container_map

for line in "${selected_pods_and_namespaces[@]}"; do
    namespace=$(echo "$line" | awk '{print $1}')
    pod=$(echo "$line" | awk '{print $2}')

    deployment=$(echo "$pod" | rev | cut -d'-' -f2- | rev)

    if [[ -n "${deployment_container_map["$namespace/$deployment"]}" ]]; then
        first_container="${deployment_container_map["$namespace/$deployment"]}"
    else
        mapfile -t containers < <(oc get pod "$pod" -n "$namespace" -o jsonpath="{.spec.containers[*].name}")

        final_containers=$(echo "${containers[@]}" | tr ' ' '\n')
        container_count=$(echo "$final_containers" | wc -l)

        if [[ $container_count -eq 1 ]]; then
            first_container="${containers[0]}"
        else
            _chdr=$(fzf_header "Container: $pod" "[Enter]     Select container" "[Esc]       Exit")
            _cpw=$(fzf_header_popup_width "$_chdr")
            _cph=$(fzf_header_popup_height "$_chdr" "$final_containers")
            first_container=$(echo "$final_containers" | fzf-tmux \
                --header="$_chdr" \
                --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
                --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
                --border-label=" $FZF_BORDER_LABEL " \
                --border-label-pos=center \
                --layout=reverse \
                -p "${_cpw},${_cph}")
            [[ -z "$first_container" ]] && continue
        fi

        first_container=$(echo "$first_container" | awk '{$1=$1};1')
        deployment_container_map["$namespace/$deployment"]="$first_container"
    fi

    if [[ ${#pod} -gt 30 ]]; then
        formatted_pod="${pod:0:15}..${pod: -15}"
    else
        formatted_pod="$pod"
    fi

    if tmux list-windows -t "$session_name" | grep -q "$formatted_pod"; then
        continue
    fi

    if [[ -n "$first_container" ]]; then
        tmux new-window -t "$session_name" -n "$formatted_pod" "oc logs -f $pod -n $namespace -c $first_container; bash"
    else
        tmux new-window -t "$session_name" -n "$formatted_pod" "oc logs -f $pod -n $namespace; bash"
    fi
    window_created=true
done

if tmux list-windows -t "$session_name" | grep -q "DELETEME"; then
    tmux kill-window -t "$session_name:0"
fi

tmux select-window -t "$session_name:0"
tmux switch-client -t "$session_name"