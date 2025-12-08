#!/bin/bash
# Deploy script for tmux workshop application on OpenShift

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
NAMESPACE="${NAMESPACE:-workshop-tmux}"
IMAGE_NAME="${IMAGE_NAME:-quay.io/chiaretto/tmux-workshop}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

cd "$PROJECT_DIR"

echo "=== Deploying tmux workshop application ==="
echo "Namespace: ${NAMESPACE}"
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
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

# Create namespace if it doesn't exist
echo "Creating namespace ${NAMESPACE}..."
oc create namespace "${NAMESPACE}" --dry-run=client -o yaml | oc apply -f -

# Apply manifests
echo "Applying manifests..."
for manifest in deploy/*.yaml; do
    if [ -f "$manifest" ]; then
        echo "  Applying $manifest..."
        oc apply -f "$manifest" -n "${NAMESPACE}"
    fi
done

# Wait for deployment
echo ""
echo "Waiting for deployment to be ready..."
oc rollout status deployment/tmux-workshop -n "${NAMESPACE}" --timeout=120s || true

# Get route URL
echo ""
ROUTE_URL=$(oc get route tmux-workshop -n "${NAMESPACE}" -o jsonpath='{.spec.host}' 2>/dev/null || echo "")
if [ -n "$ROUTE_URL" ]; then
    echo "=== Deployment completed ==="
    echo "Access the workshop at: https://${ROUTE_URL}"
else
    echo "=== Deployment completed ==="
    echo "Route not found. Create a route manually or use port-forward:"
    echo "  oc port-forward svc/tmux-workshop 8080:8080 -n ${NAMESPACE}"
fi
