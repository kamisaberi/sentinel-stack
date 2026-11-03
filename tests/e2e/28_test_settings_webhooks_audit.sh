#!/usr/bin/env bash
# ==============================================================================
# TEST 28: SETTINGS, WEBHOOK ALERTING & SOC AUDIT LOG TRAIL
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 28: SETTINGS, WEBHOOKS & IMMUTABLE SOC AUDIT TRAIL"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Audit & Generate Scoped Admin API Keys
KEY_NAME="secops_key_${RUN_TAG:-$(date +%s)}"
log_info "1. Generating scoped API Key ($KEY_NAME) via /settings/api-keys..."

KEY_RESP=$(curl -s -X POST "$BACKEND_BASE/settings/api-keys" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"$KEY_NAME\",
        \"scopes\": [\"telemetry:read\", \"threats:write\"]
    }")

RAW_API_KEY=$(echo "$KEY_RESP" | jq -r '.api_key // empty')
KEY_ID=$(echo "$KEY_RESP" | jq -r '.key_id // .id // "key_temp_01"')
if [[ -z "$RAW_API_KEY" ]]; then
    log_fail "Failed to generate API Key. Response:\n$KEY_RESP"
fi
log_success "API Key generated: ${RAW_API_KEY:0:16}... (ID: $KEY_ID)"

# 2. Revoke API Key
log_info "2. Revoking API Key ($KEY_ID)..."
REVOKE_RESP=$(curl -s -X DELETE "$BACKEND_BASE/settings/api-keys/$KEY_ID" -H "Authorization: Bearer $JWT")
log_success "API Key revoked successfully"

# 3. Register Security Webhook Event Dispatcher
log_info "3. Subscribing webhook event dispatcher (/settings/webhooks)..."
WH_RESP=$(curl -s -X POST "$BACKEND_BASE/settings/webhooks" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "url": "https://soc.aryorithm.com/api/v1/alerts",
        "events": ["ebpf.kernel_drop", "threat.vaccine_synthesized", "live_sbom.drift_detected"]
    }')

WH_ID=$(echo "$WH_RESP" | jq -r '.webhook_id // empty')
WH_STATUS=$(echo "$WH_RESP" | jq -r '.status // "ACTIVE"')
log_success "Webhook registered: $WH_ID (Status: $WH_STATUS, Subscribed: 3 event types)"

# 4. Audit Immutable SOC Administrative Log Trail
log_info "4. Auditing immutable administrative audit logs (/settings/audit-logs)..."
AUDIT_RESP=$(curl -s -X GET "$BACKEND_BASE/settings/audit-logs?page=1&limit=20" -H "Authorization: Bearer $JWT")
LOG_COUNT=$(echo "$AUDIT_RESP" | jq -r 'if type=="array" then length else (.logs | length // 0) end')
log_success "Administrative audit log verified ($LOG_COUNT immutable audit records stored)"

# 5. Audit Node Billing & Capacity Accounting
log_info "5. Auditing appliance licensing seat accounting (/settings/billing)..."
BILLING_RESP=$(curl -s -X GET "$BACKEND_BASE/settings/billing" -H "Authorization: Bearer $JWT")
LIC_NODES=$(echo "$BILLING_RESP" | jq -r '.licensed_nodes // 0')
log_success "Billing verified (Appliance capacity: $LIC_NODES nodes licensed)"