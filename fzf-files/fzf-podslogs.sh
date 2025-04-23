#!/usr/bin/env bash

project_name=$(oc project -q)

if [ -z "$project_name" -a $? -eq 0 ]; then
    tmux display -d 5000 'No project found'
    exit 0
elif [ -z "$project_name" -a $? -eq 1 ]; then
    tmux display -d 5000 'No project found. Are you connected on any OpenShift cluster?'
    exit 0
fi

session_name="logs"

if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name"
    tmux rename-window -t "$session_name:0" "DELETEME"
fi

mapfile -t selected_pods < <(
    oc get pods --field-selector=status.phase=Running --no-headers -o custom-columns=":metadata.name" |
        fzf-tmux \
            --header=$'-------------------------- Help --------------------------
[Enter]     Show pod(s) logs
[Tab]       Select pod to show log
[Ctrl-a]    Select all pods
[Esc]       Exit
----------------------------------------------------------\n\n' \
            --multi \
            --bind "ctrl-a:toggle-all" \
            --layout=reverse \
            -h 40 \
            -p "50%,50%" \
            --exact
)

[[ ${#selected_pods[@]} -eq 0 ]] && exit

processed_deployments=()

for pod in "${selected_pods[@]}"; do
    deployment=$(oc get pod "$pod" -o jsonpath="{.metadata.ownerReferences[?(@.kind=='ReplicaSet')].name}" | sed 's/-[a-z0-9]\{9\}$//')

    mapfile -t containers < <(oc get pod "$pod" -o jsonpath="{.spec.containers[*].name}")

    final_containers=$(echo "${containers[@]}" | tr ' ' '\n')
    container_count=$(echo "$final_containers" | wc -l)

    if [[ -z "$first_container" ]]; then
      if [[ $container_count -eq 1 ]]; then
          first_container="${containers[0]}"
          else
            first_container=$(echo "$final_containers" | fzf-tmux -wrap --header="Select the pods container:" --layout=reverse -h 40 -p "50%,50%" --exact) 
          [[ -z "$first_container" ]] && continue
      fi
    fi
    formatted_pod="${pod:0:15}..${pod: -15}"

    if tmux list-windows -t "$session_name" | grep -q "$formatted_pod"; then
        continue
    fi
  
    tmux send-keys -t "$(tmux display-message -p '#{pane_id}')" "history -s oc logs -f $pod -c $first_container" C-m
    tmux new-window -t "$session_name" -n "$formatted_pod" "oc logs -f $pod -c $first_container;bash"
    window_created=true
done

if tmux list-windows -t "$session_name" | grep -q "DELETEME"; then
    tmux kill-window -t "$session_name:0"
fi

tmux select-window -t "$session_name:0"
tmux switch-client -t "$session_name"