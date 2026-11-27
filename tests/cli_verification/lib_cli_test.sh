#!/usr/bin/env bash
# ==============================================================================
# ARYORITHM CLI ONE-BY-ONE VERIFICATION LIBRARY (Isolated Sandbox Engine)
# ==============================================================================
set -uo pipefail

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
DIM="\033[2m"
RESET="\033[0m"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
VERBOSE="${CLI_TEST_VERBOSE:-0}"

init_sandbox() {
    local prefix="${1:-aryo_cli_test}"
    SANDBOX="$(mktemp -d "/tmp/${prefix}_XXXXXX")"
    export SENTINEL_ROOT="$SANDBOX/ssfs"
    export SENTINEL_CACHE_DIR="$SANDBOX/cache"
    mkdir -p "$SENTINEL_ROOT" "$SENTINEL_CACHE_DIR" "$SANDBOX/work"
    trap 'rm -rf "$SANDBOX"' EXIT
}

log_section() {
    echo -e "\n${CYAN}================================================================================${RESET}"
    echo -e "${YELLOW}  $1${RESET}"
    echo -e "${CYAN}================================================================================${RESET}"
}

# run_cli_test <label> <duty> <expected_rc> <command_string>
run_cli_test() {
    local label="$1"
    local duty="$2"
    local expected_rc="$3"
    local cmd_str="$4"

    echo -e "${CYAN}[TEST]${RESET} ${label}"
    echo -e "  ${DIM}Duty : ${duty}${RESET}"
    echo -e "  ${DIM}Cmd  : ${cmd_str}${RESET}"

    local out_file="$SANDBOX/last_out.log"
    eval "$cmd_str" >"$out_file" 2>&1
    local rc=$?

    if [[ "$rc" -eq "$expected_rc" ]]; then
        echo -e "  ${GREEN}-> [PASS]${RESET} (exit=$rc)"
        PASS_COUNT=$((PASS_COUNT + 1))
        if [[ "$VERBOSE" == "1" ]]; then
            sed 's/^/     | /' "$out_file" | head -n 20
        fi
    else
        echo -e "  ${RED}-> [FAIL]${RESET} (expected exit=$expected_rc, got exit=$rc)"
        sed 's/^/     | /' "$out_file" | head -n 25
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

skip_cli_test() {
    local label="$1"
    local duty="$2"
    local reason="$3"
    echo -e "${CYAN}[TEST]${RESET} ${label}"
    echo -e "  ${DIM}Duty : ${duty}${RESET}"
    echo -e "  ${YELLOW}-> [SKIP]${RESET} (${reason})"
    SKIP_COUNT=$((SKIP_COUNT + 1))
}

print_suite_summary() {
    local suite_name="$1"
    echo -e "\n${CYAN}--------------------------------------------------------------------------------${RESET}"
    echo -e "  SUMMARY [${suite_name}]: ${GREEN}PASS=${PASS_COUNT}${RESET} | ${YELLOW}SKIP=${SKIP_COUNT}${RESET} | ${RED}FAIL=${FAIL_COUNT}${RESET}"
    echo -e "${CYAN}--------------------------------------------------------------------------------${RESET}"
    [[ "$FAIL_COUNT" -eq 0 ]]
}
