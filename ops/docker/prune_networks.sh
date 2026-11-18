#!/usr/bin/env bash
# Single Duty: Prune unused Docker networks
set -euo pipefail

echo "[*] Pruning unused Docker networks..."
docker network prune -f
echo "[+] Unused networks pruned."
