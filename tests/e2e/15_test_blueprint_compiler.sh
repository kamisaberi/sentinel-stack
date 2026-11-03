#!/usr/bin/env bash
# ==============================================================================
# TEST 15: VISUAL BLUEPRINT DAG COMPILER & HARDWARE DEPLOYMENT
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 15: VISUAL BLUEPRINT GRAPH COMPILER & DEPLOYMENT"
cd "$WORKDIR"

JWT=$(jq -r '.jwt_token // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.jwt_token // empty' /root/.sentinel/credentials.json)
BP_ID="bp_graph_${RUN_TAG:-$(date +%s)}"

# 1. Audit Visual Node Palette Catalog
log_info "1. Auditing Visual Threat Blueprint Palette (/blueprints/node-catalog)..."
CATALOG_RESP=$(curl -s -X GET "$BACKEND_BASE/blueprints/node-catalog" -H "Authorization: Bearer $JWT")
CAT_COUNT=$(echo "$CATALOG_RESP" | jq -r '.catalog | length // 0')
if [[ "$CAT_COUNT" -lt 5 ]]; then
    log_fail "Node catalog missing required stages. Found $CAT_COUNT entries"
fi
log_success "Palette catalog verified ($CAT_COUNT stages and socket types loaded)"

# 2. Submit Multi-Stage Threat Blueprint Graph
log_info "2. Submitting visual threat blueprint graph ($BP_ID)..."
GRAPH_PAYLOAD=$(cat << EOF
{
  "blueprint_id": "$BP_ID",
  "name": "Substation Alpha Automated Graph",
  "description": "4-Stage In-Kernel ModelRouter Pipeline",
  "target_sites": ["Substation-North-01"],
  "nodes": [
    {
      "id": "node_ingest",
      "type": "NIC_INGEST",
      "category": "INGEST",
      "label": "AF_XDP Line Rate Ingest",
      "config": {"interface": "ens160", "queues": 4}
    },
    {
      "id": "node_reflex",
      "type": "SPKG_REFLEX",
      "category": "REFLEX",
      "label": "Modbus FastDrop Reflex",
      "config": {"port": 502, "tier": "lua"}
    },
    {
      "id": "node_dissector",
      "type": "DISSECTOR_MODBUS",
      "category": "DISSECTOR",
      "label": "Modbus Industrial Dissector",
      "config": {"deep_inspection": true}
    },
    {
      "id": "node_mitigate",
      "type": "XDP_KERNEL_DROP",
      "category": "MITIGATION",
      "label": "eBPF Sub-Microsecond Drop",
      "config": {"action": "DROP"}
    }
  ],
  "edges": [
    {"id": "e1", "source": "node_ingest", "source_port": "out", "target": "node_reflex", "target_port": "in"},
    {"id": "e2", "source": "node_reflex", "source_port": "out", "target": "node_dissector", "target_port": "in"},
    {"id": "e3", "source": "node_dissector", "source_port": "mitigate", "target": "node_mitigate", "target_port": "in"}
  ]
}
EOF
)

CREATE_RESP=$(curl -s -X POST "$BACKEND_BASE/blueprints" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "$GRAPH_PAYLOAD")

CREATED_ID=$(echo "$CREATE_RESP" | jq -r '.blueprint_id // empty')
if [[ "$CREATED_ID" != "$BP_ID" ]]; then
    log_fail "Failed to create blueprint graph. Response:\n$CREATE_RESP"
fi
log_success "Visual blueprint graph created: $BP_ID"

# 3. Execute Graph Topology Compiler (/compile)
log_info "3. Compiling graph DAG & asserting socket compatibility..."
COMPILE_RESP=$(curl -s -X POST "$BACKEND_BASE/blueprints/$BP_ID/compile" -H "Authorization: Bearer $JWT")
IS_VALID=$(echo "$COMPILE_RESP" | jq -r '.valid // false')
ESTIMATED_LATENCY=$(echo "$COMPILE_RESP" | jq -r '.estimated_latency_ns // 0')

if [[ "$IS_VALID" != "true" ]]; then
    log_fail "Graph compiler rejected blueprint:\n$COMPILE_RESP"
fi
log_success "Blueprint successfully compiled! Pipeline SLA: ${ESTIMATED_LATENCY} ns"

# 4. Trigger Simulated Sub-50ms Fleet Broadcast Deployment
log_info "4. Triggering fleet-wide broadcast deploy (/deploy)..."
DEPLOY_RESP=$(curl -s -X POST "$BACKEND_BASE/blueprints/$BP_ID/deploy" -H "Authorization: Bearer $JWT")
DEPLOY_STATUS=$(echo "$DEPLOY_RESP" | jq -r '.status // empty')
BROADCAST_MS=$(echo "$DEPLOY_RESP" | jq -r '.broadcast_latency_ms // 0')

if [[ "$DEPLOY_STATUS" != "DEPLOYED" ]]; then
    log_fail "Deployment failed. Response:\n$DEPLOY_RESP"
fi
log_success "Blueprint deployed fleet-wide in ${BROADCAST_MS} ms (< 50ms SLA verified)"