#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONTAINER_NAME="${1:-kuma}"
SQL_SCRIPTS=(
    "$REPO_ROOT/bin/kuma/scripts/basic_config.sql"
    "$REPO_ROOT/bin/kuma/scripts/monitor_config.sql"
)

for SQL_SCRIPT in "${SQL_SCRIPTS[@]}"; do
    if [ ! -f "$SQL_SCRIPT" ]; then
        echo "Error: '$SQL_SCRIPT' not found. Run config_generator.py first."
        exit 1
    fi
    echo "Running $(basename "$SQL_SCRIPT")..."
    if ! docker exec -i "$CONTAINER_NAME" sqlite3 /app/data/kuma.db < "$SQL_SCRIPT"; then
        echo "Error: Failed to execute '$(basename "$SQL_SCRIPT")' in '$CONTAINER_NAME'."
        exit 1
    fi
done

echo "SQL scripts executed successfully."

docker exec -i "$CONTAINER_NAME" sh -c 'pkill -f "node server/server.js" || true'
docker exec -d "$CONTAINER_NAME" sh -c 'node server/server.js'
