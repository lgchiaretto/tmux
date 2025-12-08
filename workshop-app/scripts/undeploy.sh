#!/bin/bash
# Undeploy script for tmux workshop application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
NAMESPACE="${NAMESPACE:-workshop-tmux}"

echo "=== Undeploying tmux workshop application ==="
echo "Namespace: ${NAMESPACE}"
echo ""

# Check if oc is available
if ! command -v oc &>/dev/null; then
    echo "Error: oc CLI not found. Please install OpenShift CLI."
    exit 1
fi

# Check if logged in
if ! oc whoami &>/dev/null; then
    echo "Error: Not logged in to OpenShift. Please run 'oc login' first."
    exit 1
fi

# Check if namespace exists
if ! oc get namespace "${NAMESPACE}" &>/dev/null; then
    echo "Namespace ${NAMESPACE} does not exist. Nothing to undeploy."
    exit 0
fi

# Delete resources in reverse order
echo "Deleting resources..."

cd "$PROJECT_DIR"

# Delete manifests in reverse order
for manifest in $(ls -r deploy/*.yaml 2>/dev/null); do
    if [ -f "$manifest" ]; then
        echo "  Deleting $manifest..."
        oc delete -f "$manifest" -n "${NAMESPACE}" --ignore-not-found=true
    fi
done

# Optionally delete the namespace
read -p "Delete namespace ${NAMESPACE}? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting namespace ${NAMESPACE}..."
    oc delete namespace "${NAMESPACE}" --ignore-not-found=true
fi

echo ""
echo "=== Undeploy completed ==="
