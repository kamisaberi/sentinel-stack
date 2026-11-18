#!/usr/bin/env bash
# Single Duty: Spawn interactive shell inside a container
# Usage: ./exec_container_bash.sh <container_name>
set -euo pipefail

CONTAINER="${1:-}"

if [ -z "$CONTAINER" ]; then
    echo "Usage: $0 <container_name>"
    exit 1
fi

echo "[*] Opening shell in ${CONTAINER}..."
docker exec -it -u 0 "$CONTAINER" /bin/bash 2>/dev/null || docker exec -it -u 0 "$CONTAINER" /bin/sh
