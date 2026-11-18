#!/usr/bin/env bash
# ==============================================================================
# List all active edge devices and their sensor-driven attack vectors
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"

echo -e "\033[1;36m[*] Querying Active Fleet Nodes from ${NEXUS_URL}...\033[0m\n"

NODES_JSON=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes" || { echo "[-] Failed to connect to Nexus at ${NEXUS_URL}"; exit 1; })

echo "$NODES_JSON" | jq -r '.[].node_id' | while read -r NID; do
  echo -e "\033[1;32m==================================================================\033[0m"
  curl -s "${NEXUS_URL}/api/v1/fleet/nodes/${NID}" | jq '{
    node_id: .node_id,
    site: .site,
    hostname: .hostname,
    status: .status,
    sensors: [.sensors[].sensor_id],
    categories: [.sensors[].category],
    total_attacks: (.attacks | length),
    attacks: [.attacks[]]
  }'
done
echo -e "\033[1;32m==================================================================\033[0m"
