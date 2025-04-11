#!/usr/bin/env bash

project_name=$(oc project -q)

if [ -z "$project_name" -a $? -eq 0 ]; then
    tmux display -d 5000 'No project found'
    exit 0
elif [ -z "$project_name" -a $? -eq 1 ]; then
    tmux display -d 5000 'No project found. Are you connected on any OpenShift cluster?'
    exit 0
fi

session_name="${project_name}-logs"

tmux new-session -d -s "$session_name"

mapfile -t selected_pods < <(
  oc get pods --field-selector=status.phase=Running --no-headers -o custom-columns=":metadata.name" |
    fzf-tmux --prompt="Select the pods > " --multi --bind "ctrl-a:toggle-all" --header="Select the OpenShift pods:" --layout=reverse -h 40 -p "50%,50%"  --exact)

[[ ${#selected_pods[@]} -eq 0 ]] && exit

first_container=""
window_created=false

for pod in "${selected_pods[@]}"; do

    mapfile -t containers < <(oc get pod "$pod" -o jsonpath="{.spec.containers[*].name}")

    final_containers=$(echo "${containers[@]}" | tr ' ' '\n')
    container_count=$(echo "$final_containers" | wc -l)

    if [[ -z "$first_container" ]]; then
        if [[ $container_count -eq 1 ]]; then
          first_container="${containers[0]}"
        else
          first_container=$(echo "$final_containers" | fzf-tmux --header="Select the pods container:" --layout=reverse -h 40 -p "50%,50%")
          [[ -z "$first_container" ]] && continue
        fi
    fi
    formatted_pod="${pod:0:15}..${pod: -15}"
    tmux new-window -t "$session_name" -n "$formatted_pod" "oc logs -f $pod -c $first_container;bash"
    window_created=true
done

tmux kill-window -t "$session_name:0"

if $window_created; then
    tmux select-window -t "$session_name:0"
fi

tmux switch-client -t "$session_name"