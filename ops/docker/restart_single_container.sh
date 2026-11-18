#!/usr/bin/env bash
# Single Duty: Restart one specific container safely
# Usage: ./restart_single_container.sh <container_name>
set -euo pipefail

CONTAINER="${1:-}"

if [ -z "$CONTAINER" ]; then
    echo "Usage: $0 <container_name>"
    exit 1
fi

echo "[*] Restarting container: ${CONTAINER}..."
docker restart "$CONTAINER"
echo "[+] Container ${CONTAINER} restarted."
