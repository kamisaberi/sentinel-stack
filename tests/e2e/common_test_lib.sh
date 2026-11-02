#!/usr/bin/env bash
# ==============================================================================
# COMMON TEST HARNESS LIBRARY: Shared Helpers, Assertions & Config
# ==============================================================================
set -euo pipefail

# 1. Endpoints & Real Account Credentials
export SENTINEL_HUB_URL="${SENTINEL_HUB_URL:-http://localhost:8000}"
export BACKEND_BASE="${SENTINEL_HUB_URL}/api/v1"
# --- ADD UNDER WORKDIR IN tests/e2e/common_test_lib.sh ---
export RUN_TAG="$(date +%s)_$((RANDOM % 900 + 100))"

TEST_USER="${TEST_USER:-kamisaberi@gmail.com}"
TEST_PASS="${TEST_PASS:-12345678}"
TEST_NAME="${TEST_NAME:-Kamran Saberifard}"

# 2. Workspace & Log File
WORKDIR="${TEST_WORKDIR:-$(mktemp -d /tmp/aryo_e2e_run_XXXXXX)}"
LOG_FILE="$WORKDIR/suite_execution.log"

# 3. Persistent Author Key Resolution
DEV_KEY=""
KEY_CANDIDATES=(
    "/home/kami/.sentinel/keys/developer_private.pem"
    "${HOME}/.sentinel/keys/developer_private.pem"
    "/root/.sentinel/keys/developer_private.pem"
    "/etc/sentinel/keys/developer_private.pem"
)

for k in "${KEY_CANDIDATES[@]}"; do
    if [[ -f "$k" ]]; then
        DEV_KEY="$k"
        break
    fi
done
export DEV_KEY

# 4. ANSI Terminal Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# 5. Milestone & Header Logging
log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[PASS]${RESET} $1"; }
log_fail()    { echo -e "${RED}[FAIL]${RESET} $1"; exit 1; }
log_header() {
    echo -e "\n${CYAN}================================================================================${RESET}"
    echo -e "${YELLOW}  $1${RESET}"
    echo -e "${CYAN}================================================================================${RESET}"
}

# 6. Cryptographic & File Assertions
assert_http_code() {
    local url="$1"
    local expected="$2"
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$code" != "$expected" ]]; then
        log_fail "Expected HTTP $expected from $url, got HTTP $code"
    fi
}

assert_file_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        log_fail "Assertion failed: File not found: $file"
    fi
}

# 7. Sudo / User Profile Credentials Synchronizer
sync_credentials() {
    if [[ -f "$HOME/.sentinel/credentials.json" ]]; then
        mkdir -p /root/.sentinel 2>/dev/null || sudo mkdir -p /root/.sentinel
        cp "$HOME/.sentinel/credentials.json" /root/.sentinel/credentials.json 2>/dev/null || sudo cp "$HOME/.sentinel/credentials.json" /root/.sentinel/credentials.json
    fi
    if [[ -f "/home/kami/.sentinel/credentials.json" && "$HOME" != "/home/kami" ]]; then
        cp "/home/kami/.sentinel/credentials.json" "$HOME/.sentinel/credentials.json" 2>/dev/null || sudo cp "/home/kami/.sentinel/credentials.json" "$HOME/.sentinel/credentials.json"
    fi
}