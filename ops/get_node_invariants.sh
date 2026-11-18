#!/usr/bin/env bash
# ==============================================================================
# Single-Purpose: Get ONLY the formal mathematical invariants for a specific node
# Usage: ./get_node_invariants.sh [node_id | site_keyword] [--json]
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:9443}"
TARGET="${1:-}"

FLEET=$(curl -s -f "${NEXUS_URL}/api/v1/fleet/nodes" || { echo "[-] Failed to connect to Nexus"; exit 1; })

if [ -z "$TARGET" ]; then
  echo -e "\033[1;33m[*] No node specified. Active enclaves:\033[0m"
  echo "$FLEET" | jq -r '.[] | "    • \(.site) -> ID: \(.node_id)"'
  echo -e "\nUsage: $0 <node_name_or_id>"
  exit 0
fi

RESOLVED_ID=$(echo "$FLEET" | jq -r --arg q "$TARGET" '.[] | select(.node_id == $q or (.site | test($q; "i")) or (.hostname | test($q; "i"))) | .node_id' | head -n1)

if [ -z "$RESOLVED_ID" ]; then
  echo -e "\033[1;31m[-] Node matching '${TARGET}' not found.\033[0m"
  exit 1
fi

# Select enclave on server
curl -s -X POST "${NEXUS_URL}/api/v1/lab/inject" \
  -H "Content-Type: application/json" \
  -d "{\"action\":\"select_enclave\",\"node_id\":\"${RESOLVED_ID}\"}" > /dev/null

DATA=$(curl -s -f "${NEXUS_URL}/api/v1/lab/telemetry?node_id=${RESOLVED_ID}")

echo -e "\033[1;36m==================================================================\033[0m"
echo -e "\033[1;36m FORMAL INVARIANTS: $(echo "$DATA" | jq -r '.active_enclave.site') [$(echo "$DATA" | jq -r '.active_enclave.domain')]\033[0m"
echo -e "\033[1;36m==================================================================\033[0m"
echo "  Invariant Name       : $(echo "$DATA" | jq -r '.active_enclave.invariant_name')"
echo "  State Variable x(t)  : $(echo "$DATA" | jq -r '.physical_state.current_val') $(echo "$DATA" | jq -r '.active_enclave.unit') [Baseline: $(echo "$DATA" | jq -r '.active_enclave.baseline')]"
echo "  Safety Boundary Limit: $(echo "$DATA" | jq -r '.active_enclave.limit') $(echo "$DATA" | jq -r '.active_enclave.unit')"
echo "  Safety Margin h(x)   : $(echo "$DATA" | jq -r '.physical_state.cbf_barrier_h') (Safe: h(x) >= 0)"
echo "  Lyapunov Exponent    : $(echo "$DATA" | jq -r '.physical_state.lyapunov_lambda') (Stable: lambda < 0)"
echo "  Critical Margin      : $(echo "$DATA" | jq -r '.physical_state.t_crit_ms') ms"
echo "  EVT p99.999% WCET    : $(echo "$DATA" | jq -r '.evt_wcet.p99_999_us') µs"
echo "  Driver SLA Limit     : $(echo "$DATA" | jq -r '.evt_wcet.sla_limit_us') µs"
echo "  Formal Status        : $(echo "$DATA" | jq -r 'if .physical_state.is_safe then "[VERIFIED SAFE]" else "[BREACHED]" end')"
echo ""
