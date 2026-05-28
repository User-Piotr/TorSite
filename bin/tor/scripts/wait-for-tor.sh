#!/bin/sh
until python3 -c "import socket; s=socket.socket(socket.AF_UNIX); s.connect('/var/lib/tor/control'); s.close()" 2>/dev/null; do
    sleep 2
done
exec "$@"
