#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Get ONLY the primary physical apparatus of an edge sentry
# Usage: ./get_node_instrument.sh [node_id | site_keyword] [--json]
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
TARGET="${1:-}"

FLEET=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes" || { echo "[-] Failed to connect to Nexus"; exit 1; })

if [ -z "$TARGET" ]; then
  echo -e "\033[1;33m[*] No node specified. Displaying instruments for all nodes:\033[0m\n"
  echo "$FLEET" | jq -r '.[].node_id' | while read -r NID; do
    D=$(curl -s "${NEXUS_URL}/api/v1/fleet/nodes/${NID}")
    echo "  • $(echo "$D" | jq -r '.site') ($(echo "$D" | jq -r '.hostname')):"
    echo "      Title    : $(echo "$D" | jq -r '.primary_instrument.title')"
    echo "      Protocol : $(echo "$D" | jq -r '.primary_instrument.protocol')"
    echo "      Visual   : $(echo "$D" | jq -r '.primary_instrument.type')"
    echo ""
  done
  exit 0
fi

RESOLVED_ID=$(echo "$FLEET" | jq -r --arg q "$TARGET" '.[] | select(.node_id == $q or (.site | test($q; "i")) or (.hostname | test($q; "i"))) | .node_id' | head -n1)

if [ -z "$RESOLVED_ID" ]; then
  echo -e "\033[1;31m[-] Node matching '${TARGET}' not found.\033[0m"
  exit 1
fi

DATA=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes/${RESOLVED_ID}")
echo "$DATA" | jq '{site, hostname, primary_instrument}'
