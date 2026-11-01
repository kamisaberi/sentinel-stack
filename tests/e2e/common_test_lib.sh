#!/usr/bin/env bash
# ==============================================================================
# COMMON TEST HARNESS LIBRARY: Shared Helpers, Assertions & Config
# ==============================================================================
set -euo pipefail

export SENTINEL_HUB_URL="${SENTINEL_HUB_URL:-http://localhost:8000}"
export BACKEND_BASE="${SENTINEL_HUB_URL}/api/v1"

TEST_USER="${TEST_USER:-admin@aryorithm.com}"
TEST_PASS="${TEST_PASS:-password123}"
TEST_NAME="${TEST_NAME:-Security Admin}"

WORKDIR="${TEST_WORKDIR:-$(mktemp -d /tmp/aryo_e2e_run_XXXXXX)}"
LOG_FILE="$WORKDIR/suite_execution.log"

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[PASS]${RESET} $1"; }
log_fail()    { echo -e "${RED}[FAIL]${RESET} $1"; exit 1; }
log_header() {
    echo -e "\n${CYAN}================================================================================${RESET}"
    echo -e "${YELLOW}  $1${RESET}"
    echo -e "${CYAN}================================================================================${RESET}"
}

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