#!/usr/bin/env bash
# ==============================================================================
# TEST 23: CYBER RANGE DIGITAL TWIN & REAL-TIME MALWARE REPLAY
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 23: CYBER RANGE TWIN PROVISIONING & MALWARE REPLAY"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Query Pre-Engineered Cyber Range Blueprints
log_info "1. Querying available cyber range templates (/range/blueprints)..."
BP_LIST=$(curl -s -X GET "$BACKEND_BASE/range/blueprints" -H "Authorization: Bearer $JWT")
BP_SLUG=$(echo "$BP_LIST" | jq -r 'if type=="array" then .[0].blueprint_id // .[0].slug // "substation" else "substation" end')
log_success "Range template selected: $BP_SLUG"

# 2. Provision Isolated Digital Twin Enclave (10.240.0.x)
ENCLAVE_NAME="enclave_twin_${RUN_TAG:-$(date +%s)}"
log_info "2. Provisioning twin enclave ($ENCLAVE_NAME) on 10.240.0.x (/range/instances/provision)..."

PROV_RESP=$(curl -s -X POST "$BACKEND_BASE/range/instances/provision" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "{
        \"blueprint_id\": \"$BP_SLUG\",
        \"enclave_name\": \"$ENCLAVE_NAME\",
        \"duration_hours\": 1.0,
        \"traffic_profile\": \"OT_MODBUS_IEC104\"
    }")

INSTANCE_ID=$(echo "$PROV_RESP" | jq -r '.instance_id // empty')
if [[ -z "$INSTANCE_ID" ]]; then
    log_fail "Failed to provision range twin enclave. Response:\n$PROV_RESP"
fi
SANDBOX_IP=$(echo "$PROV_RESP" | jq -r '.sandbox_ip // "10.240.0.2"')
log_success "Twin enclave provisioned! ID: $INSTANCE_ID (Sandbox IP: $SANDBOX_IP)"

# 3. Test Operational Lifecycle (PAUSE -> RESUME)
log_info "3. Testing lifecycle states: PAUSE -> RESUME..."
PAUSE_RESP=$(curl -s -X POST "$BACKEND_BASE/range/instances/$INSTANCE_ID/pause" -H "Authorization: Bearer $JWT")
PAUSED_STATUS=$(echo "$PAUSE_RESP" | jq -r '.status // empty')
log_info "  ├── Enclave state: $PAUSED_STATUS"

RESUME_RESP=$(curl -s -X POST "$BACKEND_BASE/range/instances/$INSTANCE_ID/resume" -H "Authorization: Bearer $JWT")
RESUMED_STATUS=$(echo "$RESUME_RESP" | jq -r '.status // empty')
log_success "Enclave resumed: $RESUMED_STATUS"

# 4. Trigger Real-Time Malware Attack Replay
log_info "4. Injecting deterministic SCADA malware replay (POST /range/attacks/replay)..."
REPLAY_RESP=$(curl -s -X POST "$BACKEND_BASE/range/attacks/replay" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d '{
        "malware": "industroyer2_substation",
        "target": "10.240.0.10"
    }')

REPLAY_STATUS=$(echo "$REPLAY_RESP" | jq -r '.status // empty')
FRAMES=$(echo "$REPLAY_RESP" | jq -r '.frames_injected // 0')
if [[ "$REPLAY_STATUS" != "STREAMING" ]]; then
    log_fail "Attack replay failed. Response:\n$REPLAY_RESP"
fi
log_success "Attack replay active: $REPLAY_STATUS ($FRAMES frames wire-injected)"

# 5. Generate and Download Signed Resilience Certificate (PDF)
log_info "5. Generating cryptographically sealed Resilience Certificate (/range/resilience/certify)..."
CERT_PDF="$WORKDIR/resilience_audit.pdf"
curl -s -X POST "$BACKEND_BASE/range/resilience/certify" \
    -H "Authorization: Bearer $JWT" \
    -o "$CERT_PDF"

assert_file_exists "$CERT_PDF"
PDF_MAGIC=$(head -c 4 "$CERT_PDF")
if [[ "$PDF_MAGIC" != "%PDF" ]]; then
    log_fail "Resilience certificate is not a valid PDF file. Header: $PDF_MAGIC"
fi
log_success "Cryptographic Resilience Certificate downloaded: $CERT_PDF"

# 6. Terminate Twin Enclave Instance
log_info "6. Terminating test enclave instance..."
curl -s -X DELETE "$BACKEND_BASE/range/instances/$INSTANCE_ID" -H "Authorization: Bearer $JWT" >> "$LOG_FILE" 2>&1
log_success "Cyber range twin lifecycle complete and cleaned up"