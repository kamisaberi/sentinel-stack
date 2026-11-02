#!/usr/bin/env bash
# ==============================================================================
# TEST 01: REAL ACCOUNT AUTHENTICATION & TOKEN MINTING
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 01: REAL ACCOUNT AUTHENTICATION ($TEST_USER)"

log_info "1. Verifying backend health..."
assert_http_code "$SENTINEL_HUB_URL/health" "200"
log_success "Backend is healthy (HTTP 200)"

log_info "2. Authenticating as $TEST_USER..."
LOGIN_RESP=$(curl -s -X POST "$BACKEND_BASE/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_USER\",\"password\":\"$TEST_PASS\"}")

JWT_TOKEN=$(echo "$LOGIN_RESP" | jq -r '.access_token // empty')

if [[ -z "$JWT_TOKEN" ]]; then
    log_fail "Authentication failed for $TEST_USER. Response:\n$LOGIN_RESP"
fi
log_success "Successfully authenticated (JWT acquired)"

log_info "3. Minting Hub CLI API token via 'aryo login'..."
aryo login --jwt "$JWT_TOKEN" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1

# Ensure credentials exist in both user and root profiles for sudo consistency
if [[ -f "$HOME/.sentinel/credentials.json" ]]; then
    sudo mkdir -p /root/.sentinel
    sudo cp "$HOME/.sentinel/credentials.json" /root/.sentinel/credentials.json
fi
if [[ -f "/home/kami/.sentinel/credentials.json" && "$HOME" != "/home/kami" ]]; then
    sudo cp "/home/kami/.sentinel/credentials.json" "$HOME/.sentinel/credentials.json" 2>/dev/null || true
fi

log_info "4. Verifying stored identity and enrolled public key..."
aryo whoami >> "$LOG_FILE" 2>&1
log_success "Identity verified in credentials.json"