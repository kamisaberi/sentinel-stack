#!/usr/bin/env bash
# ==============================================================================
# Dispatch an attack vector or PCAP replay against a specific edge node
# Usage: ./dispatch_pcap_attack.sh <malware_or_attack_id> [target_hostname]
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
ATTACK_ID="${1:-MODBUS_FC05_OVERRIDE}"
TARGET_HOST="${2:-substation-01.matrix.internal}"

echo -e "\033[1;36m[*] Launching attack '${ATTACK_ID}' against ${TARGET_HOST} via ${NEXUS_URL}...\033[0m"

RESP=$(curl -s -X POST "${NEXUS_URL}/api/v1/range/attacks/replay" \
  -H "Content-Type: application/json" \
  -d "{\"malware\":\"${ATTACK_ID}\",\"target\":\"${TARGET_HOST}\"}")

echo -e "\033[1;32m[+] Range Response:\033[0m"
echo "$RESP" | jq . 2>/dev/null || echo "$RESP"
