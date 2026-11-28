#!/usr/bin/env bash
# ==============================================================================
# ARYORITHM INDIVIDUAL CLI TEST LIBRARY (Isolated Sandbox & Assertions)
# ==============================================================================
set -uo pipefail

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
DIM="\033[2m"
RESET="\033[0m"

VERBOSE="${CLI_TEST_VERBOSE:-0}"

init_sandbox() {
    local prefix="${1:-aryo_cmd}"
    SANDBOX="$(mktemp -d "/tmp/${prefix}_XXXXXX")"
    export SENTINEL_ROOT="$SANDBOX/ssfs"
    export SENTINEL_CACHE_DIR="$SANDBOX/cache"
    mkdir -p "$SENTINEL_ROOT" "$SENTINEL_CACHE_DIR" "$SANDBOX/work"
    trap 'rm -rf "$SANDBOX"' EXIT
}

# Usage: test_command <label> <duty> <expected_exit_code> <command_string>
test_command() {
    local label="$1"
    local duty="$2"
    local expected_rc="$3"
    local cmd_str="$4"

    echo -e "${CYAN}================================================================================${RESET}"
    echo -e "${YELLOW}[CMD]${RESET}  ${label}"
    echo -e "${DIM}Duty : ${duty}${RESET}"
    echo -e "${DIM}Exec : ${cmd_str}${RESET}"
    echo -e "${CYAN}--------------------------------------------------------------------------------${RESET}"

    local out_file="$SANDBOX/cmd_output.log"
    eval "$cmd_str" >"$out_file" 2>&1
    local rc=$?

    if [[ "$rc" -eq "$expected_rc" ]]; then
        echo -e "${GREEN}[PASS]${RESET} Exit code matched expected (${rc})."
        if [[ "$VERBOSE" == "1" ]]; then
            sed 's/^/  | /' "$out_file"
        else
            sed 's/^/  | /' "$out_file" | head -n 15
        fi
        echo -e "${CYAN}================================================================================${RESET}"
        return 0
    else
        echo -e "${RED}[FAIL]${RESET} Expected exit code ${expected_rc}, but got ${rc}."
        sed 's/^/  | /' "$out_file" | head -n 30
        echo -e "${CYAN}================================================================================${RESET}"
        return 1
    fi
}

# Usage: skip_command <label> <duty> <reason>
skip_command() {
    local label="$1"
    local duty="$2"
    local reason="$3"

    echo -e "${CYAN}================================================================================${RESET}"
    echo -e "${YELLOW}[SKIP]${RESET} ${label}"
    echo -e "${DIM}Duty   : ${duty}${RESET}"
    echo -e "${DIM}Reason : ${reason}${RESET}"
    echo -e "${CYAN}================================================================================${RESET}"
    return 0
}