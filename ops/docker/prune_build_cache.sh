#!/usr/bin/env bash
# Single Duty: Prune BuildKit build cache
set -euo pipefail

echo "[*] Pruning Docker BuildKit cache..."
docker builder prune -f
echo "[+] BuildKit cache cleared."
