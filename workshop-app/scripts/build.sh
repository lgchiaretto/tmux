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

cd "$PROJECT_DIR"

echo "=== Building tmux workshop application ==="
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Build context: $PROJECT_DIR"
echo ""

# Build the container image from workshop-app directory using unified Dockerfile
echo "Building container image..."
podman build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f Dockerfile.unified .

echo ""
echo "=== Build completed successfully ==="
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To test locally:"
echo "  podman run -it --rm -p 8080:8080 ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To push to registry:"
echo "  podman push ${IMAGE_NAME}:${IMAGE_TAG}"
