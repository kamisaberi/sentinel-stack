#!/usr/bin/env bash
# Single Duty: Free all bound Sentinel simulation ports
set -euo pipefail

echo "[*] Releasing simulation ports (9443, 9444, 50051, 15501, 15502, 8554, 8889, 2368)..."
sudo fuser -k 9443/tcp 9444/tcp 50051/tcp 15501/tcp 15502/tcp 8554/tcp 8889/tcp 2368/udp 2>/dev/null || true
echo "[+] Ports released."
