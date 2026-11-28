#!/usr/bin/env bash
# ==============================================================================
# ARYORITHM SCENARIO-BACKED INDIVIDUAL CLI TEST LIBRARY (v2)
# ==============================================================================
set -uo pipefail

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
DIM="\033[2m"
RESET="\033[0m"

VERBOSE="${CLI_TEST_VERBOSE:-0}"
KEEP_UP=0
OWNED_SCENARIO=""

parse_common_flags() {
    for arg in "$@"; do
        [[ "$arg" == "--keep-up" ]] && KEEP_UP=1
        [[ "$arg" == "--verbose" || "$arg" == "-v" ]] && VERBOSE=1
    done
}

cleanup_all() {
    if [[ -n "$OWNED_SCENARIO" && "$KEEP_UP" -eq 0 ]]; then
        echo -e "${DIM}[*] Tearing down scenario '${OWNED_SCENARIO}'...${RESET}"
        aryo scenario down "$OWNED_SCENARIO" >/dev/null 2>&1 || true
    fi
    [[ -n "${SANDBOX:-}" && -d "${SANDBOX:-}" ]] && rm -rf "$SANDBOX"
}

init_sandbox() {
    local prefix="${1:-aryo_cmd}"
    SANDBOX="$(mktemp -d "/tmp/${prefix}_XXXXXX")"
    mkdir -p "$SANDBOX/work"
    trap cleanup_all EXIT
}

# Boot a real catalog scenario from ~/.sentinel/scenarios/catalog/ if not already running
ensure_scenario_loaded() {
    local slug="$1"
    local expected_plugin="${2:-}"

    if docker ps --format '{{.Names}}' | grep -q "matrix-edge-01-${slug}"; then
        echo -e "${GREEN}[+] Reusing already-running scenario:${RESET} ${slug}"
    else
        echo -e "${CYAN}[*] Loading real scenario from catalog:${RESET} ${slug}"
        aryo scenario up "$slug" || {
            echo -e "${RED}[FAIL] Failed to boot scenario '${slug}'${RESET}"
            exit 1
        }
        OWNED_SCENARIO="$slug"
    fi

    echo -e "${DIM}[*] Waiting for matrix-nexus REST API (:9443/api/v1/fleet/nodes)...${RESET}"
    local ready=0
    for _ in $(seq 1 30); do
        if curl -sf "http://localhost:9443/api/v1/fleet/nodes" >/dev/null 2>&1; then
            ready=1
            break
        fi
        sleep 2
    done

    if [[ "$ready" -ne 1 ]]; then
        echo -e "${RED}[FAIL] matrix-nexus did not become healthy on :9443 for '${slug}'${RESET}"
        exit 1
    fi

    local nodes_count
    nodes_count=$(curl -sf "http://localhost:9443/api/v1/fleet/nodes" | jq 'length' 2>/dev/null || echo "0")
    echo -e "${GREEN}[+] Live Scenario Ready:${RESET} ${slug} | matrix-nexus healthy | registered nodes=${nodes_count}"

    if [[ -n "$expected_plugin" ]]; then
        if docker exec "matrix-edge-01-${slug}" test -f "/etc/sentinel/plugins.d/${expected_plugin}"; then
            echo -e "${GREEN}[+] Verified live cartridge plugin in edge container:${RESET} ${expected_plugin}"
        else
            echo -e "${RED}[FAIL] Expected plugin '${expected_plugin}' missing inside matrix-edge-01-${slug}${RESET}"
            exit 1
        fi
    fi
}

# Execute command and assert BOTH exit code and empirical output regex
test_command_assert() {
    local label="$1"
    local duty="$2"
    local expected_rc="$3"
    local output_regex="$4"
    local cmd_str="$5"

    echo -e "${CYAN}================================================================================${RESET}"
    echo -e "${YELLOW}[CMD]${RESET}  ${label}"
    echo -e "${DIM}Duty : ${duty}${RESET}"
    echo -e "${DIM}Exec : ${cmd_str}${RESET}"
    echo -e "${CYAN}--------------------------------------------------------------------------------${RESET}"

    local out_file="$SANDBOX/cmd_output.log"
    eval "$cmd_str" >"$out_file" 2>&1
    local rc=$?

    if [[ "$rc" -ne "$expected_rc" ]]; then
        echo -e "${RED}[FAIL]${RESET} Expected exit=${expected_rc}, got exit=${rc}."
        sed 's/^/  | /' "$out_file" | head -n 30
        return 1
    fi

    if [[ -n "$output_regex" ]] && ! grep -Eiq "$output_regex" "$out_file"; then
        echo -e "${RED}[FAIL]${RESET} Output did not satisfy empirical assertion regex: /${output_regex}/"
        sed 's/^/  | /' "$out_file" | head -n 30
        return 1
    fi

    echo -e "${GREEN}[PASS]${RESET} Exit=${rc} & empirical assertion /${output_regex}/ verified against live scenario."
    if [[ "$VERBOSE" == "1" ]]; then
        sed 's/^/  | /' "$out_file"
    else
        sed 's/^/  | /' "$out_file" | head -n 18
    fi
    echo -e "${CYAN}================================================================================${RESET}"
    return 0
}