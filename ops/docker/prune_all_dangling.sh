#!/usr/bin/env bash
# Single Duty: Prune stopped containers, dangling images, and build cache
set -euo pipefail

echo "[*] Cleaning dangling Docker assets..."
docker system prune -f
echo "[+] Dangling containers, networks, and images pruned."
