#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONTAINER_NAME="kuma-v2"
SCRIPTS=(
    "$REPO_ROOT/bin/kuma/v2/basic_config.sql"
    "$REPO_ROOT/bin/kuma/v2/monitor_config.sql"
)

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container '$CONTAINER_NAME' is not running."
    exit 1
fi

for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        echo "Error: '$script' not found."
        exit 1
    fi
    echo "Running $(basename "$script")..."
    if ! docker exec -i "$CONTAINER_NAME" sqlite3 /app/data/kuma.db < "$script"; then
        echo "Error: Failed to execute '$script'."
        exit 1
    fi
done

echo "Restarting node..."
docker exec -i "$CONTAINER_NAME" sh -c 'pkill -f "node server/server.js" || true'
docker exec -d "$CONTAINER_NAME" sh -c 'node server/server.js'

echo "Done."
