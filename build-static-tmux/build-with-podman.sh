#!/bin/bash
#
# build-with-podman.sh - Build static tmux using Podman container
#
# Usage:
#   ./build-with-podman.sh [OPTIONS]
#
# Options:
#   -v VERSION  tmux version to build (default: 3.6)
#   -c          Compress with UPX
#   -h          Show help
#

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
TMUX_VERSION="${TMUX_VERSION:-3.6}"
USE_UPX="${USE_UPX:-0}"
OUTPUT_DIR="${SCRIPT_DIR}/output"
IMAGE_NAME="tmux-static-builder"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
COLOR_END="\033[0m"

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build a static tmux binary using Podman container.

Options:
    -v VERSION  tmux version to build (default: ${TMUX_VERSION})
    -c          Compress with UPX
    -h          Show this help

Examples:
    $0                    # Build default version
    $0 -v 3.4             # Build tmux 3.4
    $0 -v 3.5 -c          # Build tmux 3.5 with UPX compression

EOF
}

log() {
    printf "%b%s%b\n" "${BLUE}" "$1" "${COLOR_END}"
}

success() {
    printf "%b%s%b\n" "${GREEN}" "$1" "${COLOR_END}"
}

error() {
    printf "%b%s%b\n" "${RED}" "$1" "${COLOR_END}"
}

# Parse arguments
while getopts "hcv:" option; do
    case $option in
        h)
            usage
            exit 0
            ;;
        c)
            USE_UPX=1
            ;;
        v)
            TMUX_VERSION="$OPTARG"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

# Check for podman
if ! command -v podman &> /dev/null; then
    error "Podman is not installed. Please install it first."
    echo "  sudo dnf install -y podman"
    exit 1
fi

# Create output directory
mkdir -p "${OUTPUT_DIR}"

log "Building container image..."
podman build -t "${IMAGE_NAME}" -f "${SCRIPT_DIR}/Containerfile" "${SCRIPT_DIR}"

log "Building static tmux ${TMUX_VERSION}..."
podman run --rm \
    -e TMUX_VERSION="${TMUX_VERSION}" \
    -e USE_UPX="${USE_UPX}" \
    -v "${OUTPUT_DIR}:/output:Z" \
    "${IMAGE_NAME}"

echo ""
success "Build completed!"
echo ""
log "Output files in ${OUTPUT_DIR}:"
ls -la "${OUTPUT_DIR}/"
