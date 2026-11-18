#!/usr/bin/env bash
# Single Duty: Set Docker daemon DNS to 1.1.1.1, 8.8.8.8
set -euo pipefail

DAEMON_JSON="/etc/docker/daemon.json"
echo "[*] Configuring DNS in ${DAEMON_JSON}..."

sudo mkdir -p /etc/docker
if [ -f "$DAEMON_JSON" ]; then
    sudo jq '.dns = ["1.1.1.1", "8.8.8.8"]' "$DAEMON_JSON" > /tmp/daemon.json.tmp
    sudo mv /tmp/daemon.json.tmp "$DAEMON_JSON"
else
    echo '{"dns": ["1.1.1.1", "8.8.8.8"]}' | sudo tee "$DAEMON_JSON" > /dev/null
fi

sudo systemctl reload-or-restart docker
echo "[+] Docker daemon DNS updated and reloaded."
