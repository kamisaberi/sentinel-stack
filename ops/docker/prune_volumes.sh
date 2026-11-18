#!/usr/bin/env bash
# Single Duty: Prune unused Docker volumes
set -euo pipefail

echo "[*] Pruning unused Docker volumes..."
docker volume prune -f
echo "[+] Unused volumes pruned."
