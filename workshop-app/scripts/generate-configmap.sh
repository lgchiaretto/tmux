#!/bin/bash
# Generate ConfigMap from guides directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "# Auto-generated ConfigMap for workshop guides"
echo "# Generated at: $(date)"
echo "apiVersion: v1"
echo "kind: ConfigMap"
echo "metadata:"
echo "  name: tmux-workshop-guides"
echo "  labels:"
echo "    app: tmux-workshop"
echo "data:"

# Process Portuguese guides
for file in guides/pt/*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        key="pt-${filename}"
        echo "  ${key}: |"
        sed 's/^/    /' "$file"
        echo ""
    fi
done

# Process English guides
for file in guides/en/*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        key="en-${filename}"
        echo "  ${key}: |"
        sed 's/^/    /' "$file"
        echo ""
    fi
done

echo ""
echo "# To apply: ./scripts/generate-configmap.sh | oc apply -f -"
