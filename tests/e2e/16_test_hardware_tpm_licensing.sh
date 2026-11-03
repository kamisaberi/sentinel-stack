#!/usr/bin/env bash
# ==============================================================================
# TEST 16: HARDWARE SILICON IDENTITY & COMMERCIAL LICENSING LIFECYCLE
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 16: HARDWARE SILICON IDENTITY & COMMERCIAL LICENSING"
cd "$WORKDIR"

# 1. Acquire valid, unexpired JWT token
JWT=$(get_jwt_token)
if [[ -z "$JWT" ]]; then
    log_fail "Failed to acquire valid JWT token."
fi

# 2. Audit Hardware Profile & Silicon Root
log_info "1. Auditing physical hardware profile & silicon root..."
aryo hardware status >> "$LOG_FILE" 2>&1

# 3. Enroll Hardware Identity Token
log_info "2. Enrolling hardware identity token into /etc/sentinel/...";
sudo aryo hardware enroll >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/hardware_identity.token"

# Extract clean hardware token string
if jq -e . /etc/sentinel/hardware_identity.token >/dev/null 2>&1; then
    HW_TOKEN=$(jq -r '.hardware_token_hash // .token_hash // .token // empty' /etc/sentinel/hardware_identity.token)
    if [[ -z "$HW_TOKEN" ]]; then
        HW_TOKEN=$(sha256sum /etc/sentinel/hardware_identity.token | awk '{print $1}')
    fi
else
    HW_TOKEN=$(tr -d ' \n\r"' < /etc/sentinel/hardware_identity.token)
fi

log_success "Clean hardware token extracted: ${HW_TOKEN:0:24}..."

# 4. Fetch Master Ed25519 Public Key
log_info "3. Fetching Master Ed25519 Public Key from backend (/licenses/public-key)..."
PUBKEY_RESP=$(curl -s "$BACKEND_BASE/licenses/public-key")
if [[ -z "$PUBKEY_RESP" ]]; then
    log_fail "Failed to retrieve license master public key."
fi
log_success "Master license verification key acquired"

# 5. Subscribe Node & Issue Commercial License
log_info "4. Subscribing commercial appliance node (/licenses/subscribe)..."
SUB_PAYLOAD=$(cat << EOF
{
  "plan_slug": "enterprise",
  "hardware_token": "$HW_TOKEN",
  "hostname": "sentinel-edge-node-01",
  "customer_name": "Aryorithm Critical Infrastructure"
}
EOF
)

SUB_RESP=$(curl -s -X POST "$BACKEND_BASE/licenses/subscribe" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "$SUB_PAYLOAD")

LICENSE_ID=$(echo "$SUB_RESP" | jq -r '.license_id // empty')
if [[ -z "$LICENSE_ID" ]]; then
    log_fail "Failed to subscribe commercial license. Response:\n$SUB_RESP"
fi
log_success "Commercial license generated: $LICENSE_ID"

# 6. Download Offline Air-Gapped .lic File
log_info "5. Downloading offline 1-year .lic envelope (/licenses/portal-download)..."
LIC_FILE="$WORKDIR/appliance_license.lic"
curl -s -X POST "$BACKEND_BASE/licenses/portal-download" \
    -H "Authorization: Bearer $JWT" \
    -H "Content-Type: application/json" \
    -d "{\"hardware_token\": \"$HW_TOKEN\", \"days_valid\": 365}" \
    -o "$LIC_FILE"

assert_file_exists "$LIC_FILE"
log_success "Offline license file downloaded: $LIC_FILE"

# 7. Apply License Locally to Runtime
log_info "6. Applying license to /etc/sentinel/license.lic..."
sudo aryo license apply "$LIC_FILE" >> "$LOG_FILE" 2>&1
assert_file_exists "/etc/sentinel/license.lic"

# 8. Inspect License Entitlements Locally
log_info "7. Inspecting cryptographic license entitlements..."
aryo license inspect "$LIC_FILE" >> "$LOG_FILE" 2>&1

# 9. Cryptographic Signature Verification on Backend (Querying unique LICENSE_ID)
log_info "8. Verifying license signature on backend (/licenses/verify/$LICENSE_ID)..."
VERIFY_RESP=$(curl -s -X GET "$BACKEND_BASE/licenses/verify/$LICENSE_ID" -H "Authorization: Bearer $JWT")
IS_VALID=$(echo "$VERIFY_RESP" | jq -r '.signature_valid // false')
STATUS=$(echo "$VERIFY_RESP" | jq -r '.status // "unknown"')

if [[ "$IS_VALID" != "true" ]]; then
    log_fail "License signature verification failed. Response:\n$VERIFY_RESP"
fi
log_success "Cryptographic license verified authentic ($LICENSE_ID, status: $STATUS)"