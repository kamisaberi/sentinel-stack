#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Get ONLY the attack vectors mapped to a specific edge node
# Usage: ./get_node_attacks.sh [node_id | site_keyword] [--json]
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
TARGET="${1:-}"
OUTPUT_JSON=false

if [ "${2:-}" = "--json" ] || [ "${TARGET}" = "--json" ]; then
  OUTPUT_JSON=true
  if [ "${TARGET}" = "--json" ]; then TARGET=""; fi
fi

# Fetch fleet list
FLEET=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes" || { echo "[-] Failed to connect to Nexus at ${NEXUS_URL}"; exit 1; })

if [ -z "$TARGET" ]; then
  echo -e "\033[1;33m[*] No node specified. Available active nodes:\033[0m"
  echo "$FLEET" | jq -r '.[] | "    • \(.site) (\(.hostname)) -> ID: \(.node_id)"'
  echo -e "\nUsage: $0 <node_name_or_id> [--json]"
  exit 0
fi

# Resolve node
RESOLVED_ID=$(echo "$FLEET" | jq -r --arg q "$TARGET" '.[] | select(.node_id == $q or (.site | test($q; "i")) or (.hostname | test($q; "i"))) | .node_id' | head -n1)

if [ -z "$RESOLVED_ID" ]; then
  echo -e "\033[1;31m[-] Node matching '${TARGET}' not found.\033[0m"
  exit 1
fi

DATA=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes/${RESOLVED_ID}")

if [ "$OUTPUT_JSON" = true ]; then
  echo "$DATA" | jq '{site, hostname, attacks}'
else
  SITE=$(echo "$DATA" | jq -r '.site')
  HOST=$(echo "$DATA" | jq -r '.hostname')
  COUNT=$(echo "$DATA" | jq -r '.attacks | length')
  
  echo -e "\033[1;36m==================================================================\033[0m"
  echo -e "\033[1;36m ATTACK SURFACE: ${SITE} (${HOST}) [${COUNT} EXPLOITS]\033[0m"
  echo -e "\033[1;36m==================================================================\033[0m"
  printf "  \033[1;33m%-28s\033[0m %s\n" "ATTACK IDENTIFIER" "AUDIT / DISPLAY NAME"
  echo "  ----------------------------------------------------------------"
  echo "$DATA" | jq -r '.attacks[] | "\(.id)|\(.name)"' | while IFS="|" read -r AID ANAME; do
    printf "  %-28s %s\n" "${AID}" "${ANAME}"
  done
  echo ""
fi
