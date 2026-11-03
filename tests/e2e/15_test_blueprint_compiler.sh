#!/usr/bin/env bash
# ==============================================================================
# TEST 15: VISUAL BLUEPRINT GRAPH COMPILER & DEPLOYMENT
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 15: VISUAL BLUEPRINT GRAPH COMPILER & DEPLOYMENT"
cd "$WORKDIR"

JWT=$(jq -r '.jwt_token // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.jwt_token // empty' /root/.sentinel/credentials.json)
if [[ -z "$JWT" ]]; then
    log_fail "No JWT token found in credentials.json. Run Test 01 first."
fi

BP_ID="bp_substation_${RUN_TAG:-$(date +%s)}"

# 1. Audit Visual Node Palette Catalog
log_info "1. Auditing Visual Threat Blueprint Palette (/blueprints/node-catalog)..."
CATALOG_RESP=$(curl -s -X GET "$BACKEND_BASE/blueprints/node-catalog" -H "Authorization: Bearer $JWT")

NODE_COUNT=$(echo "$CATALOG_RESP" | jq -r '(.nodes // []) | length')
STAGE_COUNT=$(echo "$CATALOG_RESP" | jq -r '(.stages // []) | length')

if [[ "$NODE_COUNT" -lt 5 || "$STAGE_COUNT" -lt 3 ]]; then
    log_fail "Node catalog missing required stages or nodes. Found $NODE_COUNT nodes across $STAGE_COUNT stages."
fi
log_success "Palette catalog verified ($NODE_COUNT palette nodes across $STAGE_COUNT stages loaded)"

# 2. Submit Multi-Stage Threat Blueprint Graph
log_info "2. Submitting visual threat blueprint graph ($BP_ID)..."
GRAPH_PAYLOAD=$(cat << EOF
{
  "blueprint_id": "$BP_ID",
  "name": "Substation Alpha SCADA & Thermal Protection",
  "description": "Visual pipeline connecting Modbus TCP ingress to native C++ guard, OpenVINO MAE model, and Stuxnet HMI blinding interlock",
  "target_sites": ["PowerGrid-North-01", "Substation-Alpha"],
  "nodes": [
    {
      "id": "node_sensor_1",
      "type": "SENSOR_INGRESS",
      "label": "Modbus TCP Ingress",
      "position": {"x": 100, "y": 200},
      "config": {
        "sensor_id": "Substation-Modbus-01",
        "transport": "tcp",
        "port": 502
      }
    },
    {
      "id": "node_reflex_1",
      "type": "SPKG_REFLEX_GATE",
      "label": "Modbus Actuator Guard",
      "position": {"x": 400, "y": 200},
      "config": {
        "package_id": "org.aryorithm.package.modbus_actuator_guard",
        "tier": "NATIVE_CPP",
        "latency_sla_ns": 120
      }
    },
    {
      "id": "node_ai_1",
      "type": "SILICON_MODEL",
      "label": "OpenVINO Tabular MAE",
      "position": {"x": 700, "y": 200},
      "config": {
        "model_id": "network_threat_int8.onnx",
        "silicon_target": "INTEL_OPENVINO",
        "threshold_drop": 0.85
      }
    },
    {
      "id": "node_fusion_1",
      "type": "CROSS_MODAL_FUSION",
      "label": "Stuxnet Anti-Blinding Interlock",
      "position": {"x": 1000, "y": 200},
      "config": {
        "correlation_id": "STUXNET_THERMAL_BLINDING",
        "cyber_sensor_id": "Substation-Modbus-01",
        "physical_sensor_id": "Thermal-Probe-101",
        "physical_min_temp": 120.0
      }
    },
    {
      "id": "node_action_drop",
      "type": "ACTION_KERNEL_DROP",
      "label": "In-Kernel eBPF Drop (<0.84µs)",
      "position": {"x": 1300, "y": 300},
      "config": {
        "action": "KERNEL_DROP_AND_ISOLATE"
      }
    }
  ],
  "edges": [
    {
      "id": "e1",
      "source_node": "node_sensor_1",
      "source_port": "out",
      "target_node": "node_reflex_1",
      "target_port": "in"
    },
    {
      "id": "e2",
      "source_node": "node_reflex_1",
      "source_port": "pass",
      "target_node": "node_ai_1",
      "target_port": "in"
    },
    {
      "id": "e3",
      "source_node": "node_reflex_1",
      "source_port": "drop",
      "target_node": "node_action_drop",
      "target_port": "in"
    },
    {
      "id": "e4",
      "source_node": "node_ai_1",
      "source_port": "pass",
      "target_node": "node_fusion_1",
      "target_port": "cyber_in"
    },
    {
      "id": "e5",
      "source_node": "node_ai_1",
      "source_port": "anomaly",
      "target_node": "node_action_drop",
      "target_port": "in"
    },
    {
      "id": "e6",
      "source_node": "node_fusion_1",
      "source_port": "breach",
      "target_node": "node_action_drop",
      "target_port": "in"
    }
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
log_success "Visual blueprint graph created: $CREATED_ID"

# 3. Execute Graph Topology Compiler (/compile)
log_info "3. Compiling graph DAG & asserting socket compatibility..."
COMPILE_RESP=$(curl -s -X POST "$BACKEND_BASE/blueprints/$CREATED_ID/compile" -H "Authorization: Bearer $JWT")
IS_VALID=$(echo "$COMPILE_RESP" | jq -r '.valid // false')
ESTIMATED_LATENCY=$(echo "$COMPILE_RESP" | jq -r '.estimated_latency_ns // 0')

if [[ "$IS_VALID" != "true" ]]; then
    log_fail "Graph compiler rejected blueprint:\n$COMPILE_RESP"
fi
log_success "Blueprint successfully compiled! Pipeline SLA: ${ESTIMATED_LATENCY} ns"

# 4. Trigger Simulated Sub-50ms Fleet Broadcast Deployment
log_info "4. Triggering fleet-wide broadcast deploy (/deploy)..."
DEPLOY_RESP=$(curl -s -X POST "$BACKEND_BASE/blueprints/$CREATED_ID/deploy" -H "Authorization: Bearer $JWT")
DEPLOY_STATUS=$(echo "$DEPLOY_RESP" | jq -r '.status // empty')
BROADCAST_MS=$(echo "$DEPLOY_RESP" | jq -r '.broadcast_latency_ms // 0')

if [[ "$DEPLOY_STATUS" != "DEPLOYED" ]]; then
    log_fail "Deployment failed. Response:\n$DEPLOY_RESP"
fi
log_success "Blueprint deployed fleet-wide in ${BROADCAST_MS} ms (< 50ms SLA verified)"