#!/bin/bash
# Build script for tmux workshop application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
# Root of tmux project (parent of workshop-app)
TMUX_ROOT="$(dirname "$PROJECT_DIR")"

# Configuration
IMAGE_NAME="${IMAGE_NAME:-quay.io/chiaretto/tmux-workshop}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

cd "$TMUX_ROOT"

echo "=== Building tmux workshop application ==="
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Build context: $TMUX_ROOT"
echo ""

# Build the container image from the tmux root directory
echo "Building container image..."
podman build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f workshop-app/Dockerfile .

echo ""
echo "=== Build completed successfully ==="
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To test locally:"
echo "  podman run -it --rm -p 8080:8080 ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To push to registry:"
echo "  podman push ${IMAGE_NAME}:${IMAGE_TAG}"
