#!/bin/bash
# Build and deploy script - builds the image and deploys to OpenShift

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Build and Deploy tmux Workshop ==="
echo ""

# Build the image
"$SCRIPT_DIR/build.sh"

echo ""
echo "=== Pushing image to registry ==="
IMAGE_NAME="${IMAGE_NAME:-quay.io/chiaretto/tmux-workshop}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
podman push "${IMAGE_NAME}:${IMAGE_TAG}"

echo ""
# Deploy to OpenShift
"$SCRIPT_DIR/deploy.sh"
