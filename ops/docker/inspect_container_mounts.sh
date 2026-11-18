#!/usr/bin/env bash
# Single Duty: Inspect all volume mounts and binds of a container
# Usage: ./inspect_container_mounts.sh <container_name>
set -euo pipefail

CONTAINER="${1:-matrix-nexus}"
echo "[*] Inspecting mounts for container: ${CONTAINER}..."

docker inspect "$CONTAINER" | jq -r '.[0].Mounts[] | "\(.Type)\t \(.Destination) \t<-- \(.Source)"'
