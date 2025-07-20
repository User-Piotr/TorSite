#!/bin/bash

set -e # Exit on error
VENV_DIR="venv"

source "$VENV_DIR/bin/activate"
echo -e "Starting debugpy...\n"
python -Xfrozen_modules=off -m debugpy --listen 5678 --wait-for-client ./config_generator.py monitor_config --master_onion_address "https://dummy.onion"
echo -e "\nDebugpy exited."
deactivate
