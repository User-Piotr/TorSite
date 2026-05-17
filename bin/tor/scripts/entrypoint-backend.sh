#!/bin/sh
set -e

BOOTSTRAP_TIMEOUT=600  # 10 minutes

# Create the hidden service directory and copy config from /etc/tor
mkdir -p /var/lib/tor/hidden_service
cp /etc/tor/ob_config /var/lib/tor/hidden_service/ob_config

# Set strict permissions that Tor requires
chmod 700 /var/lib/tor/hidden_service
chmod 600 /var/lib/tor/hidden_service/ob_config

# Start Tor and capture PID
tor -f "/etc/tor/torrc" &
TOR_PID=$!

# Wait for log file (max 30s)
ELAPSED=0
while [ ! -f /var/log/tor/notices.log ]; do
    if [ $ELAPSED -ge 30 ]; then
        echo "Log file never appeared. Tor failed to start."
        kill $TOR_PID 2>/dev/null || true
        exit 1
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

# Wait for bootstrap with timeout
ELAPSED=0
echo "Waiting for Tor to establish a connection..."
while ! grep -q "Bootstrapped 100% (done): Done" /var/log/tor/notices.log; do
    if [ $ELAPSED -ge $BOOTSTRAP_TIMEOUT ]; then
        echo "Bootstrap timeout after ${BOOTSTRAP_TIMEOUT}s. Exiting for restart."
        kill $TOR_PID 2>/dev/null || true
        exit 1
    fi
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

# Start Vanguards after Tor is ready
echo "Starting Vanguards..."
exec vanguards
