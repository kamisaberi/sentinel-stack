#!/usr/bin/env bash
# ==============================================================================
# PHASE 5: PROVISION ALL 50 REAL-WORLD SCENARIOS INTO SSFS CATALOG
# Usage: bash scripts/05_provision_scenarios.sh [optional_prefixes: 01 05 ...]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RECIPES_DIR="${STACK_ROOT}/scenarios/scripts"

[[ ! -d "${RECIPES_DIR}" ]] && { echo "[-] Missing recipes dir: ${RECIPES_DIR}"; exit 1; }

if [[ -n "${SENTINEL_ROOT:-}" ]]; then
    TARGET_ROOT="${SENTINEL_ROOT}"; RUN_USER=""
elif [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    TARGET_ROOT="$(getent passwd "${SUDO_USER}" | cut -d: -f6)/.sentinel"; RUN_USER="${SUDO_USER}"
elif [[ "${EUID}" -eq 0 ]]; then
    TARGET_ROOT="/var/lib/sentinel"; RUN_USER=""
else
    TARGET_ROOT="${HOME}/.sentinel"; RUN_USER=""
fi

echo "=== [PHASE 5] Provisioning 50 Real-World Scenarios -> ${TARGET_ROOT}/scenarios/catalog ==="
mapfile -t ALL_RECIPES < <(find "${RECIPES_DIR}" -maxdepth 1 -type f -name "[0-9][0-9]_*.sh" | sort)

SELECTED=()
if [[ "$#" -gt 0 ]]; then
    for prefix in "$@"; do
        for r in "${ALL_RECIPES[@]}"; do
            [[ "$(basename "${r}")" == ${prefix}* ]] && SELECTED+=("${r}")
        done
    done
else
    SELECTED=("${ALL_RECIPES[@]}")
fi

TOTAL="${#SELECTED[@]}"; PASSED=0; FAILED=0
for recipe in "${SELECTED[@]}"; do
    rname="$(basename "${recipe}")"
    echo -e "\n\033[36m[*] Provisioning [$((PASSED + FAILED + 1))/${TOTAL}]: ${rname}...\033[0m"
    if [[ -n "${RUN_USER}" ]]; then
        sudo -u "${RUN_USER}" SENTINEL_ROOT="${TARGET_ROOT}" bash "${recipe}" && PASSED=$((PASSED + 1)) || FAILED=$((FAILED + 1))
    else
        SENTINEL_ROOT="${TARGET_ROOT}" bash "${recipe}" && PASSED=$((PASSED + 1)) || FAILED=$((FAILED + 1))
    fi
done

echo "=========================================================================="
echo "[+] Scenario Provisioning Summary: ${PASSED}/${TOTAL} succeeded | ${FAILED} failed"
echo "=========================================================================="
[[ "${FAILED}" -eq 0 ]]
