#!/usr/bin/env bash
# Single Duty: List all environment variables inside a container
# Usage: ./inspect_container_env.sh <container_name>
set -euo pipefail

CONTAINER="${1:-matrix-edge-substation-01}"
echo "[*] Environment variables for container: ${CONTAINER}:"

docker inspect "$CONTAINER" | jq -r '.[0].Config.Env[]' | sort
