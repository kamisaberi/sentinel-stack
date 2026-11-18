#!/usr/bin/env bash
# Single Duty: Inspect sentinel-grid-net bridge topology
set -euo pipefail

NET_NAME="${1:-sentinel-grid-net}"
echo "[*] Inspecting network topology for: ${NET_NAME}..."

docker network inspect "${NET_NAME}" | jq -r '.[0].Containers | to_entries[] | "\(.value.Name) \t \(.value.IPv4Address) \t \(.value.MacAddress)"' | sort -k2
