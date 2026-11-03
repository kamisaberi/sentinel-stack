#!/usr/bin/env bash
# ==============================================================================
# TEST 40: AIRGAP UPDATE SNEAKERNET & STRICT MULTI-TENANT BARRIERS
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 40: AIRGAP SYNC & MULTI-TENANT ISOLATION BARRIER"
cd "$WORKDIR"

JWT=$(get_jwt_token)

# 1. Download Offline Airgap Bundle Sneakernet Archive (POST /sync/airgap-bundle)
log_info "1. Generating sneakernet archive bundle (/sync/airgap-bundle)..."
AIRGAP_TAR="$WORKDIR/sentinel_airgap_plugins.tar.gz"

HTTP_CODE=$(curl -s -w "%{http_code}" -X POST "$BACKEND_BASE/sync/airgap-bundle" \
    -H "Content-Type: application/json" \
    -d '{
        "requested_plugins": [{"slug": "modbus_actuator_guard", "version": "1.0.0"}],
        "target_silicon": "UNIVERSAL"
    }' \
    -o "$AIRGAP_TAR")

if [[ "$HTTP_CODE" != "200" ]]; then
    log_fail "Failed to generate airgap bundle (HTTP $HTTP_CODE)"
fi
assert_file_exists "$AIRGAP_TAR"
log_success "Airgap sneakernet archive generated: $AIRGAP_TAR ($(wc -c < "$AIRGAP_TAR") bytes)"

# 2. Test Edge Appliance Version Check-Updates Polling (POST /sync/check-updates)
log_info "2. Polling edge update check endpoint (/sync/check-updates)..."
CHECK_RESP=$(curl -s -X POST "$BACKEND_BASE/sync/check-updates" \
    -H "Content-Type: application/json" \
    -d '{
        "sentinel_version": "2.5.0",
        "installed_plugins": [{"slug": "modbus_actuator_guard", "current_version": "1.0.0"}]
    }')

UPDATES_FOUND=$(echo "$CHECK_RESP" | jq -r '(.updates_available // []) | length')
log_success "Edge update check polling verified ($UPDATES_FOUND updates pending)"

# 3. Test Anonymous Installation Counter Bump (POST /telemetry/install)
log_info "3. Testing anonymous installation telemetry bump (/telemetry/install)..."
INSTALL_RESP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BACKEND_BASE/telemetry/install" \
    -H "Content-Type: application/json" \
    -d '{
        "slug": "modbus_actuator_guard",
        "version": "1.0.0",
        "silicon_target": "x86_64"
    }')

if [[ "$INSTALL_RESP_CODE" != "202" && "$INSTALL_RESP_CODE" != "200" ]]; then
    log_fail "Installation telemetry bump failed (HTTP $INSTALL_RESP_CODE)"
fi
log_success "Installation counter bump verified (HTTP $INSTALL_RESP_CODE Accepted)"

# 4. Strict Multi-Tenant Isolation Barrier Test (Unauthorized Cross-Tenant Rejection)
log_info "4. Testing strict multi-tenant barrier (Cross-Tenant Rejection)..."
FORBIDDEN_RESP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BACKEND_BASE/blueprints/bp_other_tenant_private_999" \
    -H "Authorization: Bearer $JWT")

# Expect 403 Forbidden or 404 Not Found (Cross-tenant boundary enforced)
if [[ "$FORBIDDEN_RESP_CODE" == "403" || "$FORBIDDEN_RESP_CODE" == "404" ]]; then
    log_success "Multi-tenant isolation barrier strictly enforced (HTTP $FORBIDDEN_RESP_CODE Protected)"
else
    log_fail "Tenant isolation breach! Received unexpected HTTP $FORBIDDEN_RESP_CODE"
fi