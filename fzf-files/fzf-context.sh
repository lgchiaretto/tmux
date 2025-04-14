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
    cluster="${cluster%%-*}"
    CONTEXTS["$cluster"]="$context"
done < <(yq -r '.contexts[] | .context.cluster + " " + .name' "$KUBECONFIG")

if [[ ${#CONTEXTS[@]} -eq 0 ]]; then
    tmux display -d 5000 "No cluster found in kubeconfig file."
    exit 0
fi

FILTER=${1:-}
current_context=$(oc config current-context)

declare -A CLUSTERS_PROJECTS
for cluster in "${!CONTEXTS[@]}"; do
    {
        context="${CONTEXTS[$cluster]}"
        namespaces=$(oc --context="$context" get namespaces --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
        if [[ -n "$namespaces" ]]; then
            for project in $namespaces; do
                echo "$cluster/$project"
            done
        fi
    } &
done | sort > /tmp/clusters_projects.$$

wait

if [[ ! -s /tmp/clusters_projects.$$ ]]; then
    tmux display -d 5000 "No project found in the clusters. Maybe you are not connected to a cluster!"
    rm -f /tmp/clusters_projects.$$
    exit 0
fi

selected_cluster_project=$(fzf-tmux --header="Select the OCP context" --layout=reverse -h 40 -p "50%,50%" --query="$FILTER" --exact < /tmp/clusters_projects.$$)
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

