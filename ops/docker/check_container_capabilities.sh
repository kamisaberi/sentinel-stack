#!/usr/bin/env bash
# Single Duty: Check Linux capabilities of an edge container
# Usage: ./check_container_capabilities.sh <container_name>
set -euo pipefail

CONTAINER="${1:-matrix-edge-substation-01}"
echo "[*] Checking capabilities for container: ${CONTAINER}..."

docker inspect "$CONTAINER" | jq '{
  Name: .[0].Name,
  Privileged: .[0].HostConfig.Privileged,
  CapAdd: .[0].HostConfig.CapAdd,
  CapDrop: .[0].HostConfig.CapDrop
}'
