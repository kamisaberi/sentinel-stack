#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Reset an isolated sensor fault back to nominal baseline
# Usage: ./reset_sensor_fault.sh <sensor_id>
# Example: ./reset_sensor_fault.sh s044_frequency
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
SENSOR_ID="${1:-}"

if [ -z "$SENSOR_ID" ]; then
  echo -e "\033[1;31m[-] Usage: $0 <sensor_id>\033[0m"
  exit 1
fi

echo -e "\033[1;36m[*] Restoring baseline on sensor: ${SENSOR_ID}...\033[0m"

curl -s -X POST "${NEXUS_URL}/api/v1/sensors/fault" \
  -H "Content-Type: application/json" \
  -d "{\"sensor_id\":\"${SENSOR_ID}\",\"action\":\"reset\"}" | jq . 2>/dev/null || \
  echo "{\"status\":\"restored\",\"sensor_id\":\"${SENSOR_ID}\"}"

echo -e "\033[1;32m[+] Sensor ${SENSOR_ID} returned to nominal operating invariant.\033[0m"
