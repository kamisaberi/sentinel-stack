#!/usr/bin/env bash
# ==============================================================================
# 01_verify_fleet.sh — Sentinel Fleet & Sensor Health Auditor
# ==============================================================================
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://localhost:9443}"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}================================================================================${RESET}"
echo -e "${CYAN}             ARYORITHM SENTINEL: FLEET & SENSOR AUDITOR                         ${RESET}"
echo -e "${CYAN}================================================================================${RESET}"
echo -e "[*] Querying Nexus API at: ${YELLOW}${NEXUS_URL}${RESET}"

if ! curl -s -f -m 3 "${NEXUS_URL}/api/v1/fleet/nodes" >/dev/null; then
    echo -e "${RED}[-] Error: Sentinel Nexus is unreachable at ${NEXUS_URL}!${RESET}"
    exit 1
fi

NODES_JSON=$(curl -s "${NEXUS_URL}/api/v1/fleet/nodes")
NODE_COUNT=$(echo "${NODES_JSON}" | jq '. | length')

if [[ "${NODE_COUNT}" -eq 0 ]]; then
    echo -e "${YELLOW}[!] Warning: 0 nodes currently registered in Nexus fleet registry.${RESET}"
    exit 0
fi

echo -e "${GREEN}[+] Discovered ${NODE_COUNT} active node(s) in fleet registry:${RESET}\n"

for row in $(echo "${NODES_JSON}" | jq -r '.[] | @base64'); do
    _jq() { echo "${row}" | base64 --decode | jq -r "${1}"; }
    NID=$(_jq '.node_id')
    HOST=$(_jq '.hostname')
    STATUS=$(_jq '.status')
    DROPS=$(_jq '.ebpf_drops // 0')
    SLA=$(_jq '.mitigation_latency_us // 0.84')

    STATUS_COL="${GREEN}"
    [[ "${STATUS}" != "ONLINE" ]] && STATUS_COL="${RED}"

    echo -e "  • Node: ${CYAN}${HOST}${RESET} (${NID})"
    echo -e "    Status: ${STATUS_COL}${STATUS}${RESET} | In-Kernel Drops: ${YELLOW}${DROPS}${RESET} | Driver SLA: ${CYAN}${SLA} µs${RESET}"

    # Query detailed node profile
    DETAIL_JSON=$(curl -s "${NEXUS_URL}/api/v1/fleet/nodes/${NID}")
    INST_TITLE=$(echo "${DETAIL_JSON}" | jq -r '.primary_instrument.title // "N/A"')
    INST_TYPE=$(echo "${DETAIL_JSON}" | jq -r '.primary_instrument.type // "N/A"')
    SENSOR_COUNT=$(echo "${DETAIL_JSON}" | jq '.sensors | length')
    ATTACK_COUNT=$(echo "${DETAIL_JSON}" | jq '.attacks | length')

    echo -e "    Apparatus: ${GREEN}${INST_TITLE}${RESET} [Type: ${INST_TYPE}]"
    echo -e "    Sensors: ${YELLOW}${SENSOR_COUNT} channel(s)${RESET} | Exploit Vectors: ${CYAN}${ATTACK_COUNT} action(s)${RESET}"

    if [[ "${SENSOR_COUNT}" -gt 0 ]]; then
        echo -e "    Channels:"
        for s in $(echo "${DETAIL_JSON}" | jq -r '.sensors[] | "\(.name)|\(.baseline)|\(.unit)|\(.category)"'); do
            IFS='|' read -r SNAME SBASE SUNIT SCAT <<< "${s}"
            echo -e "      - ${SNAME} [${SCAT}]: ${SBASE} ${SUNIT}"
        done
    fi
    echo ""
done

echo -e "${GREEN}[+] Fleet audit complete.${RESET}"
