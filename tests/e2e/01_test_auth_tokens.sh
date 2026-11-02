#!/usr/bin/env bash
# ==============================================================================
# TEST 01: REAL ACCOUNT AUTHENTICATION & TOKEN MINTING
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 01: REAL ACCOUNT AUTHENTICATION ($TEST_USER)"

# 1. Verify Backend Health
log_info "1. Verifying backend health..."
assert_http_code "$SENTINEL_HUB_URL/health" "200"
log_success "Backend is healthy (HTTP 200)"

# 2. Authenticate and acquire fresh JWT
log_info "2. Authenticating as $TEST_USER..."
LOGIN_RESP=$(curl -s -X POST "$BACKEND_BASE/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_USER\",\"password\":\"$TEST_PASS\"}")

JWT_TOKEN=$(echo "$LOGIN_RESP" | jq -r '.access_token // empty')

if [[ -z "$JWT_TOKEN" ]]; then
    log_fail "Authentication failed for $TEST_USER. Response:\n$LOGIN_RESP"
fi
log_success "Successfully authenticated (JWT acquired)"

# 3. Mint Hub CLI API token via 'aryo login'
log_info "3. Minting Hub CLI API token via 'aryo login'..."
aryo login --jwt "$JWT_TOKEN" --hub-url "$SENTINEL_HUB_URL" >> "$LOG_FILE" 2>&1

# 4. Safely synchronize credentials between /root and /home/kami
CRED_SRC="$HOME/.sentinel/credentials.json"

if [[ "$HOME" == "/root" ]]; then
    if [[ -d "/home/kami" ]]; then
        mkdir -p /home/kami/.sentinel
        cp "$CRED_SRC" /home/kami/.sentinel/credentials.json
        chown -R kami:kami /home/kami/.sentinel 2>/dev/null || true
    fi
else
    if [[ -d "/root" ]]; then
        sudo mkdir -p /root/.sentinel
        sudo cp "$CRED_SRC" /root/.sentinel/credentials.json
    fi
fi

# 5. Verify and display the updated credentials file
log_info "4. Verifying stored identity and updated credentials.json..."
aryo whoami >> "$LOG_FILE" 2>&1

if [[ -f "$CRED_SRC" ]]; then
    echo -e "${CYAN}Updated credentials in $CRED_SRC:${RESET}"
    cat "$CRED_SRC"
fi

log_success "Identity and author keys successfully saved and verified"