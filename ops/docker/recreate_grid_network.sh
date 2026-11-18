#!/usr/bin/env bash
# Single Duty: Recreate sentinel-grid-net (10.240.0.0/24)
set -euo pipefail

NET_NAME="sentinel-grid-net"
SUBNET="10.240.0.0/24"
GATEWAY="10.240.0.1"

echo "[*] Recreating ${NET_NAME} (${SUBNET})..."
docker network rm "${NET_NAME}" 2>/dev/null || true
docker network create --driver bridge --subnet "${SUBNET}" --gateway "${GATEWAY}" "${NET_NAME}"
echo "[+] Network ${NET_NAME} ready."
