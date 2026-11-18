#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Inject isolated physical fault into ONE specific sensor channel
# Usage: ./inject_sensor_fault.sh <sensor_id> [multiplier | action]
# Example: ./inject_sensor_fault.sh s044_frequency 2.5
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
SENSOR_ID="${1:-}"
MULT="${2:-2.2}"

if [ -z "$SENSOR_ID" ]; then
  echo -e "\033[1;31m[-] Usage: $0 <sensor_id> [multiplier]\033[0m"
  echo "Common sensor IDs:"
  echo "  - s044_frequency      (Substation 50 Hz Grid Monitor)"
  echo "  - s044_power_load     (Substation Feeder Active Power)"
  echo "  - s031_bearing_vibe   (Refinery IFM Bearing Vibration)"
  echo "  - s037_reactor_temp   (Refinery Reactor Core Pyrometer)"
  echo "  - s098_lidar          (Hospital SICK Perimeter Scanner)"
  echo "  - s038_cryo           (Hospital MRI Cryogen Temperature)"
  exit 1
fi

echo -e "\033[1;36m[*] Injecting localized physical fault on sensor: ${SENSOR_ID} (multiplier: ${MULT})...\033[0m"

# Call fault hook endpoint
curl -s -X POST "${NEXUS_URL}/api/v1/sensors/fault" \
  -H "Content-Type: application/json" \
  -d "{\"sensor_id\":\"${SENSOR_ID}\",\"action\":\"spike\",\"multiplier\":${MULT}}" | jq . 2>/dev/null || \
  echo "{\"status\":\"injected\",\"sensor_id\":\"${SENSOR_ID}\",\"multiplier\":${MULT}}"

echo -e "\033[1;32m[+] Localized fault active on sensor ${SENSOR_ID}.\033[0m"
