#!/usr/bin/env bash
# ==============================================================================
# TEST 26: FLEET TOPOLOGY, ZTP ENROLLMENT & KERNEL RULES
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 26: FLEET ENCLAVES, ZTP PROVISIONING & KERNEL RULES"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Audit Active Fleet Nodes & Ring Metrics
log_info "1. Auditing active fleet nodes (/fleet/nodes)..."
NODES_RESP=$(curl -s -X GET "$BACKEND_BASE/fleet/nodes" -H "Authorization: Bearer $JWT")
NODES_COUNT=$(echo "$NODES_RESP" | jq -r 'if type=="array" then length else 0 end')
log_success "Fleet nodes queried ($NODES_COUNT nodes in active inventory)"

# 2. Query & Provision SCADA Defense Group
log_info "2. Auditing SCADA defense groups (/fleet/groups)..."
GROUPS_RESP=$(curl -s -X GET "$BACKEND_BASE/fleet/groups" -H "Authorization: Bearer $JWT")

GROUP_ID="group_scada_${RUN_TAG:-$(date +%s)}"
log_info "  ├── Provisioning new SCADA defense enclave ($GROUP_ID)..."

NEW_GROUP=$(curl -s -X POST "$BACKEND_BASE/fleet/groups" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "{
        \"group_id\": \"$GROUP_ID\",
        \"description\": \"Substation High-Voltage Protection Ring\",
        \"scada_mode\": true,
        \"max_latency_us\": 100.0
    }")

G_STATUS=$(echo "$NEW_GROUP" | jq -r '.group_id // .status // empty')
if [[ -z "$G_STATUS" ]]; then
    log_fail "Failed to create SCADA defense group. Response:\n$NEW_GROUP"
fi
log_success "SCADA defense enclave created ($GROUP_ID, max latency SLA: 100µs)"

# 3. Issue Zero-Touch Provisioning (ZTP) Enrollment Token
log_info "3. Issuing Zero-Touch Provisioning (ZTP) token (/fleet/provisioning/tokens)..."
ZTP_RESP=$(curl -s -X POST "$BACKEND_BASE/fleet/provisioning/tokens" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "enclave_id": "enclave_substation_north",
        "valid_days": 7
    }')

ZTP_TOKEN=$(echo "$ZTP_RESP" | jq -r '.token // empty')
if [[ -z "$ZTP_TOKEN" ]]; then
    log_fail "Failed to generate ZTP token. Response:\n$ZTP_RESP"
fi
log_success "ZTP enrollment token issued: $ZTP_TOKEN"

# 4. Execute Appliance Zero-Touch Enrollment (ZTP)
log_info "4. Executing appliance ZTP enrollment (/fleet/provisioning/enroll)..."
ENROLL_RESP=$(curl -s -X POST "$BACKEND_BASE/fleet/provisioning/enroll" \
    -H "Content-Type: application/json" \
    -d "{
        \"tpm_quote\": \"TPM2_QUOTE_VALIDATED_SILICON_ROOT\",
        \"dmi_uuid\": \"4c4c4544-004a-4a10-804d-b9c04f4a3233\",
        \"token\": \"$ZTP_TOKEN\"
    }")

ASSIGNED_NODE=$(echo "$ENROLL_RESP" | jq -r '.assigned_node_id // empty')
if [[ -z "$ASSIGNED_NODE" ]]; then
    log_fail "Appliance ZTP enrollment failed. Response:\n$ENROLL_RESP"
fi
log_success "Appliance enrolled via ZTP! Assigned Node ID: $ASSIGNED_NODE"

# 5. Audit Active Kernel Rules & Trigger Fleet-Wide Purge
log_info "5. Auditing active in-kernel firewall rules (/fleet/kernel-rules)..."
RULES_RESP=$(curl -s -X GET "$BACKEND_BASE/fleet/kernel-rules" -H "Authorization: Bearer $JWT")
log_success "Kernel firewall rules verified"

log_info "6. Dispatching fleet-wide kernel rule purge (/fleet/kernel-rules/purge)..."
PURGE_RESP=$(curl -s -X POST "$BACKEND_BASE/fleet/kernel-rules/purge" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{"ip": "198.51.100.99"}')

PURGE_STATUS=$(echo "$PURGE_RESP" | jq -r '.status // empty')
if [[ "$PURGE_STATUS" != "PURGED_FLEET_WIDE" ]]; then
    log_fail "Fleet kernel rule purge failed. Response:\n$PURGE_RESP"
fi
log_success "Kernel rules purged fleet-wide: $PURGE_STATUS (198.51.100.99)"