#!/usr/bin/env bash
# Single Duty: Force stop and remove all matrix-* containers
set -euo pipefail

echo "[*] Terminating matrix-* simulation containers..."
docker rm -f $(docker ps -aq --filter "name=matrix-") 2>/dev/null || true
echo "[+] Matrix containers stopped and removed."
