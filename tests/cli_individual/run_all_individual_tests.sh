#!/usr/bin/env bash
# ==============================================================================
# MASTER RUNNER: Executes All Individual Scenario-Backed CLI Verification Scripts
# Usage: bash run_all_individual_tests.sh [subdir_filter] [--verbose]
# ==============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILTER="${1:-}"
EXTRA_FLAG=""
[[ "${1:-}" == "--verbose" || "${2:-}" == "--verbose" ]] && EXTRA_FLAG="--verbose"
[[ "$FILTER" == "--verbose" ]] && FILTER=""

PASS=0
FAIL=0
FAILED_LIST=()

while IFS= read -r script; do
    if bash "$script" $EXTRA_FLAG; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        FAILED_LIST+=("$script")
    fi
done < <(find "$SCRIPT_DIR/$FILTER" -type f -name '[0-9][0-9]_*.sh' | sort)

echo -e "\n\033[1;36m================================================================================\033[0m"
echo -e "  INDIVIDUAL CLI SUITE SUMMARY: \033[1;32mPASS=${PASS}\033[0m | \033[1;31mFAIL=${FAIL}\033[0m"
if [[ "$FAIL" -gt 0 ]]; then
    echo -e "  \033[1;31mFailed Scripts:\033[0m"
    for f in "${FAILED_LIST[@]}"; do
        echo "    - $f"
    done
fi
echo -e "\033[1;36m================================================================================\033[0m"
[[ "$FAIL" -eq 0 ]]