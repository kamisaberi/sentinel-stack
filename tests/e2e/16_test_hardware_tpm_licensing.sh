#!/usr/bin/env bash
# ==============================================================================
# TEST 16: HARDWARE ROOT OF TRUST & CRYPTOGRAPHIC LICENSING LIFECYCLE
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 16: HARDWARE SILICON IDENTITY & COMMERCIAL LICENSING"
cd "$WORKDIR"

JWT=$(jq -r '.jwt_token // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.jwt_token // empty' /root/.sentinel/credentials.json)
if [[ -z "$JWT" ]]; then
    log_fail "No JWT token found in credentials.json. Run Test 01 first."
fi

# 1. Audit Hardware Profile & TPM 2.0 Identity
log_info "1. Auditing physical hardware profile & silicon root..."
aryo hardware status >> "$LOG_FILE" 2>&1

# 2. Enroll Hardware Identity Token
log_info "2. Enrolling hardware identity token into /etc/sentinel/..."
sudo aryo hardware enroll >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/hardware_identity.token"

HW_TOKEN=$(cat /etc/sentinel/hardware_identity.token | tr -d ' \n\r')
log_success "Hardware identity enrolled: ${HW_TOKEN:0:16}..."

# 3. Retrieve Master License Verification Key
log_info "3. Fetching Master Ed25519 Public Key from backend (/licenses/public-key)..."
PUBKEY_RESP=$(curl -s "$BACKEND_BASE/licenses/public-key")
if [[ -z "$PUBKEY_RESP" ]]; then
    log_fail "Failed to retrieve license master public key."
fi
log_success "Master license verification key acquired"

# 4. Subscribe Node & Issue Commercial License Envelope
log_info "4. Subscribing commercial appliance node (/licenses/subscribe)..."
SUB_RESP=$(curl -s -X POST "$BACKEND_BASE/licenses/subscribe" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "{
        \"plan_slug\": \"enterprise\",
        \"hardware_token\": \"$HW_TOKEN\",
        \"hostname\": \"sentinel-edge-node-01\",
        \"customer_name\": \"Aryorithm Critical Infrastructure\"
    }")

LICENSE_ID=$(echo "$SUB_RESP" | jq -r '.license_id // empty')
if [[ -z "$LICENSE_ID" ]]; then
    log_fail "Failed to subscribe commercial license. Response:\n$SUB_RESP"
fi
log_success "Commercial license generated: $LICENSE_ID"

# 5. Download Offline Air-Gapped .lic License File
log_info "5. Downloading offline 1-year .lic envelope (/licenses/portal-download)..."
LIC_FILE="$WORKDIR/appliance_license.lic"
curl -s -X POST "$BACKEND_BASE/licenses/portal-download" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "{\"hardware_token\": \"$HW_TOKEN\", \"days_valid\": 365}" \
    -o "$LIC_FILE"

assert_file_exists "$LIC_FILE"
log_success "Offline license file downloaded: $LIC_FILE"

# 6. Apply License to Appliance Runtime
log_info "6. Applying license to /etc/sentinel/license.lic..."
sudo aryo license apply "$LIC_FILE" >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/license.lic"

# 7. Inspect License Entitlements Locally
log_info "7. Inspecting cryptographic license entitlements..."
aryo license inspect "$LIC_FILE" >> "$LOG_FILE" 2>&1

# 8. Cryptographic Signature Verification via Backend
log_info "8. Verifying license signature on backend (/licenses/verify/$LICENSE_ID)..."
VERIFY_RESP=$(curl -s -X GET "$BACKEND_BASE/licenses/verify/$LICENSE_ID" -H "Authorization: Bearer $JWT")
IS_VALID=$(echo "$VERIFY_RESP" | jq -r '.signature_valid // false')

if [[ "$IS_VALID" != "true" ]]; then
    log_fail "License signature verification failed. Response:\n$VERIFY_RESP"
fi
log_success "Cryptographic license verified authentic ($LICENSE_ID)"