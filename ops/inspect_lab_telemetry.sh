#!/usr/bin/env bash
# ==============================================================================
# Inspect live scientific invariant telemetry across all edge enclaves
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"

echo -e "\033[1;36m[*] Fetching Sentinel-Bench Invariant Telemetry from ${NEXUS_URL}...\033[0m\n"

NODES_JSON=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes" || { echo "[-] Failed to connect to Nexus"; exit 1; })

echo "$NODES_JSON" | jq -r '.[] | "\(.node_id)|\(.site)|\(.hostname)"' | while IFS="|" read -r NID SITE HOST; do
  echo -e "\033[1;33m--- Target Enclave: ${SITE} (${HOST}) ---\033[0m"
  
  # Select enclave on server
  curl -s -X POST "${NEXUS_URL}/api/v1/lab/inject" \
    -H "Content-Type: application/json" \
    -d "{\"action\":\"select_enclave\",\"node_id\":\"${NID}\"}" > /dev/null
  
  # Query telemetry
  curl -s "${NEXUS_URL}/api/v1/lab/telemetry?node_id=${NID}" | jq '{
    enclave: .active_enclave.site,
    domain: .active_enclave.domain,
    invariant_name: .active_enclave.invariant_name,
    variable: .active_enclave.variable_name,
    current_val: "\(.physical_state.current_val) \(.active_enclave.unit)",
    barrier_h: .physical_state.cbf_barrier_h,
    is_safe: .physical_state.is_safe,
    p99_999_wcet: "\(.evt_wcet.p99_999_us) µs",
    driver_sla: "\(.evt_wcet.sla_limit_us) µs",
    pmu_ipc: .pmu_metrics.ipc,
    llc_miss_pct: "\(.pmu_metrics.llc_miss_pct)%"
  }'
  echo ""
done
