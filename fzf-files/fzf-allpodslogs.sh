#!/bin/bash -x

project_name=$(oc project -q)

if [ -z "$project_name" -a $? -eq 0 ]; then
    tmux display -d 5000 'No project found'
    exit 0
elif [ -z "$project_name" -a $? -eq 1 ]; then
    tmux display -d 5000 'No project found. Are you connected on any OpenShift cluster?'
    exit 0
fi

mapfile -t selected_pods_and_namespaces < <(
  oc get pods -A --field-selector=status.phase=Running --no-headers -o custom-columns="NAMESPACE:.metadata.namespace,POD:.metadata.name" |
    fzf-tmux --prompt="Select the pods > " --multi --header="Select the OpenShift pods (NAMESPACE | POD):" --layout=reverse -h 40 -p "50%,50%" --exact |
    awk '{print $1 " " $2}'
)

[[ ${#selected_pods_and_namespaces[@]} -eq 0 ]] && exit

declare -A namespace_map
for line in "${selected_pods_and_namespaces[@]}"; do
    namespace=$(echo "$line" | awk '{print $1}')
    namespace_map["$namespace"]=1
done

selected_namespaces=("${!namespace_map[@]}")

if [[ ${#selected_namespaces[@]} -gt 1 ]]; then
    session_name="logs"
else
    session_name="logs" # FIX this
fi

tmux new-session -d -s "$session_name"

first_container=""
window_created=false

processed_namespaces=()

for line in "${selected_pods_and_namespaces[@]}"; do
    namespace=$(echo "$line" | awk '{print $1}')
    pod=$(echo "$line" | awk '{print $2}')

    mapfile -t containers < <(oc get pod "$pod" -n "$namespace" -o jsonpath="{.spec.containers[*].name}")

    final_containers=$(echo "${containers[@]}" | tr ' ' '\n')
    container_count=$(echo "$final_containers" | wc -l)

    first_container=""
    if [[ $container_count -eq 1 ]]; then
        first_container="${containers[0]}"
    elif [[ ! " ${processed_namespaces[@]} " =~ " ${namespace} " ]]; then
        first_container=$(echo "$final_containers" | fzf-tmux --header="Select the container for pod $pod in namespace $namespace:" --layout=reverse -h 40 -p "50%,50%")
        [[ -z "$first_container" ]] && continue
        processed_namespaces+=("$namespace")
    else
        first_container="${containers[0]}"
    fi

    if [[ "$first_container" == *" "* ]]; then
        first_container=$(echo "$first_container" | awk '{print $1}')
    fi

    formatted_pod="${pod:0:15}..${pod: -15}"

    if tmux list-windows -t "$session_name" | grep -q "$formatted_pod"; then
        continue
    fi

    if [[ -n "$first_container" ]]; then
        tmux new-window -t "$session_name" -n "$formatted_pod" "oc logs -f $pod -n $namespace -c $first_container;bash"
    else
        tmux new-window -t "$session_name" -n "$formatted_pod" "oc logs -f $pod -n $namespace;bash"
    fi
    window_created=true
done

# Switch to window 0 in the logs session
tmux select-window -t "$session_name:0"

tmux switch-client -t "$session_name"