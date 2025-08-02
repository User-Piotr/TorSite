#!/bin/sh

set -e

# Create the hidden service directory and copy config from /etc/tor
mkdir -p /var/lib/tor/hidden_service
cp /etc/tor/ob_config /var/lib/tor/hidden_service/ob_config

# Set strict permissions that Tor requires
chmod 700 /var/lib/tor/hidden_service
chmod 600 /var/lib/tor/hidden_service/ob_config

# Start Tor in the background
tor -f "/etc/tor/torrc" &

# Wait for the log file to be created
while [ ! -f /var/log/tor/notices.log ]; do
    sleep 1
done

# Wait for the log file to indicate that Tor is fully bootstrapped
echo "Waiting for Tor to establish a connection..."
while ! grep -q "Bootstrapped 100% (done): Done" /var/log/tor/notices.log; do
    sleep 1
done

# Start Vanguard after Tor is ready
echo "Starting Vanguard..."
exec vanguards
