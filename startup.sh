#!/bin/bash

# Exit on error
set -e

# Define defaults
SERVICE_NAME="tor-backend"
VENV_DIR="venv"
domains=()

# Function to check if a container is healthy
check_health() {
    local service="$1"
    local retries=30
    local count
    local service_status

    echo -e "\nService ${service} has ${REPLICAS} replicas."
    echo -e "Checking health of service ${service}, waiting for all replicas to become healthy...\n"

    for instance in $(seq 1 "${REPLICAS}"); do
        count=0
        service_status="starting"
        while [ "$service_status" != "healthy" ] && [ $count -lt $retries ]; do
            service_status=$(docker inspect --format='{{.State.Health.Status}}' "${PROJECT_NAME}-${service}-${instance}")
            if [ "$service_status" = "healthy" ]; then
                echo "Service ${service}-${instance} is healthy."
            else
                echo "Waiting for ${service}-${instance} to become healthy..."
                sleep 10
                count=$((count + 1))
            fi
        done

        if [ "$service_status" != "healthy" ]; then
            echo "Service ${service}-${instance} failed to become healthy after $((retries * 10)) seconds."
            exit 1
        fi
    done
}

# docker compose wrapper
compose() {
    docker compose -p "$PROJECT_NAME" -f docker-compose.yaml "$@"
}

# Load environment variables from .env file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${SCRIPT_DIR}/.env" ]; then
    set -a
    source "${SCRIPT_DIR}/.env"
    set +a
else
    echo ".env file not found at ${SCRIPT_DIR}/.env"
    exit 1
fi

# Check if critical variables are set
if [ -z "$PROJECT_NAME" ] || [ -z "$REPLICAS" ]; then
    echo "Critical variables are not set."
    exit 1
fi

# Check if the virtual environment directory exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Please run 'make install' to set up the virtual environment."
    exit 1
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "Directory does not exist: $DIRECTORY"
    echo "Attempting to create directory..."
    mkdir -p "$DIRECTORY" &&
        echo "Directory created successfully." ||
        echo "Failed to create directory."
else
    echo "Directory already exists: $DIRECTORY"
fi

# Get .onion hostname — auto-discover the .onion subdirectory
ONION_DIR=$(find "${DIRECTORY}" -maxdepth 1 -type d -name "*.onion" | head -n 1)

if [ -z "$ONION_DIR" ]; then
    echo "No .onion subdirectory found in ${DIRECTORY}."
    exit 1
fi

if [ -f "${ONION_DIR}/hostname" ]; then
    echo "File exists: ${ONION_DIR}/hostname"
    hostname_value=$(sudo cat "${ONION_DIR}/hostname")
else
    echo "File does not exist: ${ONION_DIR}/hostname"
    echo "Unable to proceed without hostname file."
    exit 1
fi

# Generate the ob_config file
python3 ./scripts/config_generator.py ob_config --master_onion_address "${hostname_value}"

echo "Setting up directories..."

# Set permissions and ownership for the directory
if [ -d "$DIRECTORY" ]; then
    chmod -R 700 "$DIRECTORY"
    chown -R 100:101 "$DIRECTORY"
else
    echo "Directory $DIRECTORY does not exist."
    exit 1
fi

# BUILD=true  → build locally from Dockerfiles (default)
# BUILD=false → pull from GHCR using TAG (latest or specific version)
BUILD_FLAGS=""
if [ "${BUILD:-true}" = "true" ]; then
    BUILD_FLAGS="--build --force-recreate --pull never"
fi

echo "Running docker-compose..."

# Start backends first — frontend needs their domains to generate config.yaml
compose --profile backend up -d --force-recreate $BUILD_FLAGS
check_health "$SERVICE_NAME"

for instance in $(seq 1 "$REPLICAS"); do
    container_name="${PROJECT_NAME}-${SERVICE_NAME}-${instance}"
    domain=$(./scripts/domain.sh "$container_name")
    domains+=("$domain")
done

# Derive the container-internal key path from the discovered .onion directory.
# Volume ./domain is mounted at /hs_keys inside the container.
KEY_LOCATION="/hs_keys/$(basename "$ONION_DIR")/hs_ed25519_secret_key"

# Generate frontend and monitoring configs now that backend domains are known.
python3 ./scripts/config_generator.py config --log_level "$LOG_LEVEL" --log_location "$LOG_LOCATION" --domains "${domains[@]}" --key_path "$KEY_LOCATION"
python3 ./scripts/config_generator.py monitor_config --master_onion_address "http://${hostname_value}"

# Start frontend now that config.yaml exists
compose --profile frontend up -d --force-recreate $BUILD_FLAGS

# Start monitoring if enabled
if [ "${MONITORING:-false}" = "true" ]; then
    compose --profile monitoring up -d $BUILD_FLAGS
fi

# Deactivate the virtual environment
deactivate

echo -e "\nStartup script completed."
echo "You can now access your Tor service at the following addresses: http://${hostname_value}"
