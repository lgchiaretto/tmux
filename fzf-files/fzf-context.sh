#!/bin/bash

KUBECONFIG=~/.kube/config

if [[ ! -f "$KUBECONFIG" ]]; then
    tmux display -d 5000 "Error: File $KUBECONFIG does not exist."
    exit 0
fi

declare -A CONTEXTS
while IFS= read -r line; do
    cluster_full="${line%% *}"
    context="${line##* }"
    cluster="${cluster_full#api-}"
    cluster=$(echo "$cluster" | cut -d'-' -f1,2)
    CONTEXTS["$cluster"]="$context"
done < <(yq -r '.contexts[] | .context.cluster + " " + .name' "$KUBECONFIG")

if [[ ${#CONTEXTS[@]} -eq 0 ]]; then
    tmux display -d 5000 "No cluster found in kubeconfig file."
    exit 0
fi

FILTER=${1:-}
current_context=$(timeout 0.2 oc config current-context)

list_projects() {
    local cluster="$1"
    local context="$2"
    namespaces=$(timeout 0.2 oc --context="$context" get namespaces --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
    if [[ -n "$namespaces" ]]; then
        while IFS= read -r ns; do
            echo "$cluster/$ns"
        done <<< "$namespaces"
    fi
}

export -f list_projects
export KUBECONFIG

for cluster in "${!CONTEXTS[@]}"; do
    echo "$cluster ${CONTEXTS[$cluster]}"
done | xargs -n2 -P4 bash -c 'list_projects "$0" "$1"' | sort > /tmp/clusters_projects.$$

if [[ ! -s /tmp/clusters_projects.$$ ]]; then
    tmux display -d 5000 "No project found in the clusters. Maybe you are not connected to a cluster!"
    rm -f /tmp/clusters_projects.$$
    exit 0
fi

selected_cluster_project=$(fzf-tmux --header="Select the OCP context" --layout=reverse -h 40 -p "50%,50%" --query="$FILTER" --bind 'tab:accept' --exact < /tmp/clusters_projects.$$)

rm -f /tmp/clusters_projects.$$

if [[ -n "$selected_cluster_project" ]]; then
    cluster="${selected_cluster_project%%/*}"
    project="${selected_cluster_project##*/}"
    oc config use-context "${CONTEXTS[$cluster]}" > /dev/null 2>&1
    oc project "$project" > /dev/null 2>&1
    tmux display -d 1000 "You are connected to the cluster $cluster and project $project."
else
    tmux display -d 5000 "No cluster/project selected. Goodbye!"
fi
