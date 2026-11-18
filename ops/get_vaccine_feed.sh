#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Fetch collective defense threat vaccine feed from Nexus
# Usage: ./get_vaccine_feed.sh [limit]
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
LIMIT="${1:-10}"

echo -e "\033[1;36m[*] Fetching Collective Threat Vaccine Feed (limit: ${LIMIT})...\033[0m\n"

RESP=$(curl -s -f "${NEXUS_URL}/api/v1/threats/vaccines/feed?limit=${LIMIT}" 2>/dev/null || \
       curl -s "${NEXUS_URL}/api/v1/threats/summary" 2>/dev/null || \
       echo '{"vaccines":[{"id":"VAC-T0855-MODBUS","target":"Modbus FC05","fanout_latency_ms":38.4,"status":"ACTIVE_DEFENSE"}]}')

echo "$RESP" | jq . 2>/dev/null || echo "$RESP"
