#!/usr/bin/env bash
# ==============================================================================
# Inject isolated perturbation or stress against a specific edge node
# Usage: ./inject_node_perturbation.sh <node_id_or_keyword> [spike|safe|blast|fuzzer|reset]
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
TARGET="${1:-}"
ACTION="${2:-spike}"

if [ -z "$TARGET" ]; then
  echo -e "\033[1;31m[-] Usage: $0 <node_id_or_site_keyword> [spike|safe|blast|fuzzer|reset]\033[0m"
  echo "Available nodes:"
  curl -s "${NEXUS_URL}/api/v1/fleet/nodes" | jq -r '.[] | "  - \(.node_id) (\(.site))"'
  exit 1
fi

# Resolve node ID by keyword search if needed
RESOLVED_ID=$(curl -s "${NEXUS_URL}/api/v1/fleet/nodes" | jq -r --arg q "$TARGET" '.[] | select(.node_id == $q or (.site | test($q; "i")) or (.hostname | test($q; "i"))) | .node_id' | head -n1)

if [ -z "$RESOLVED_ID" ]; then
  echo -e "\033[1;31m[-] Could not resolve node matching '${TARGET}'\033[0m"
  exit 1
fi

echo -e "\033[1;36m[*] Injecting action '${ACTION}' on target node: ${RESOLVED_ID}...\033[0m"
curl -s -X POST "${NEXUS_URL}/api/v1/lab/inject" \
  -H "Content-Type: application/json" \
  -d "{\"action\":\"${ACTION}\",\"node_id\":\"${RESOLVED_ID}\"}" | jq .

echo -e "\n\033[1;32m[+] Verification: Querying target state...\033[0m"
curl -s "${NEXUS_URL}/api/v1/lab/telemetry?node_id=${RESOLVED_ID}" | jq '{
  enclave: .active_enclave.site,
  current_val: .physical_state.current_val,
  barrier_h: .physical_state.cbf_barrier_h,
  is_safe: .physical_state.is_safe,
  p99_999_wcet: .evt_wcet.p99_999_us,
  llc_miss_pct: .pmu_metrics.llc_miss_pct
}'
