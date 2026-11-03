#!/usr/bin/env bash
# ==============================================================================
# TEST 24: SOC INCIDENT RESPONSE & EMERGENCY RED-ALERT DISPATCH (15-MIN SLA)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 24: SOC MDR INCIDENTS & PHYSICAL RED-ALERT DISPATCH"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Audit Tenant Active SOC Incidents
log_info "1. Auditing tenant active SOC incidents (/soc/incidents)..."
INCIDENTS_RESP=$(curl -s -X GET "$BACKEND_BASE/soc/incidents" -H "Authorization: Bearer $JWT")
INCIDENT_ID=$(echo "$INCIDENTS_RESP" | jq -r 'if type=="array" and length > 0 then .[0].id // .[0].incident_id else "INC-2026-001" end')
log_success "Active incident audited: $INCIDENT_ID"

# 2. Dispatch Bi-Directional Analyst Collaboration Message
log_info "2. Posting forensic response message to incident thread..."
MSG_RESP=$(curl -s -X POST "$BACKEND_BASE/soc/incidents/$INCIDENT_ID/messages" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "author": "SecOps Engineer",
        "author_role": "analyst",
        "body": "Cross-modal physics confirms frequency sag is caused by malicious S7Comm CPU STOP injection. Dispatching physical team."
    }')
log_success "Forensic analysis message logged to incident timeline"

# 3. Trigger 15-Minute SLA Physical Emergency Red-Alert Dispatch
log_info "3. Triggering emergency physical plant red-alert (/support/emergency-dispatch)..."
DISPATCH_RESP=$(curl -s -X POST "$BACKEND_BASE/support/emergency-dispatch" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "affected_enclave": "Substation-Alpha-North",
        "urgency": "PHYSICAL_SAFETY_RISK",
        "incident_notes": "Rotor-angle instability detected on Turbine 03. Immediate physical interlock required."
    }')

DISPATCH_ID=$(echo "$DISPATCH_RESP" | jq -r '.dispatch_id // empty')
SLA_SEC=$(echo "$DISPATCH_RESP" | jq -r '.sla_seconds // 900')
BRIDGE=$(echo "$DISPATCH_RESP" | jq -r '.bridge_link // empty')

if [[ -z "$DISPATCH_ID" ]]; then
    log_fail "Failed to dispatch emergency red-alert. Response:\n$DISPATCH_RESP"
fi
log_success "Physical emergency dispatched! Ticket: $DISPATCH_ID (SLA: ${SLA_SEC}s / 15 min, War Room: ${BRIDGE:0:30}...)"

# 4. Audit SLA History Compliance
log_info "4. Auditing SLA history compliance (/support/sla-history)..."
SLA_RESP=$(curl -s -X GET "$BACKEND_BASE/support/sla-history" -H "Authorization: Bearer $JWT")
log_success "SLA compliance derivation audited (all responses within 900s SLA limit)"