#!/usr/bin/env bash
set -e

echo "Initializing workshop container..."

# Setup periodic updatedb in background
# Update the database every hour to include any new files created during workshop
(
  while true; do
    sleep 3600  # Run every hour
    /usr/bin/updatedb 2>/dev/null || true
  done
) &

echo "Starting workshop application..."

# Start the Node.js server
exec node server.js
