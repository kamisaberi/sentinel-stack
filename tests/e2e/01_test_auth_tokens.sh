#!/usr/bin/env bash
# ==============================================================================
# TEST 01: AUTHENTICATION, REGISTRY TOKENS & IDENTITY
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 01: AUTHENTICATION & API KEY EXCHANGE"

log_info "1. Verifying backend health..."
assert_http_code "$SENTINEL_HUB_URL/health" "200"
log_success "Backend is healthy (HTTP 200)"

log_info "2. Logging into backend ($TEST_USER)..."
LOGIN_RESP=$(curl -s -X POST "$BACKEND_BASE/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_USER\",\"password\":\"$TEST_PASS\"}")

JWT_TOKEN=$(echo "$LOGIN_RESP" | jq -r '.access_token // empty')

if [[ -z "$JWT_TOKEN" ]]; then
    log_info "User not registered. Registering test admin account..."
    REG_RESP=$(curl -s -X POST "$BACKEND_BASE/auth/register" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$TEST_NAME\",\"email\":\"$TEST_USER\",\"password\":\"$TEST_PASS\"}")
    JWT_TOKEN=$(echo "$REG_RESP" | jq -r '.access_token // empty')
fi

if [[ -z "$JWT_TOKEN" ]]; then
    log_fail "Failed to acquire JWT token from backend: $LOGIN_RESP"
fi
log_success "JWT acquired successfully"

log_info "3. Executing 'aryo login' to mint long-lived API Key..."
aryo login --jwt "$JWT_TOKEN" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1

log_info "4. Verifying stored credentials..."
aryo whoami >> "$LOG_FILE" 2>&1
assert_file_exists "$HOME/.sentinel/credentials.json"
log_success "Identity stored in ~/.sentinel/credentials.json and verified"