#!/usr/bin/env bash
# ==============================================================================
# MASTER CLI VERIFICATION RUNNER (One-by-One Command Audit)
# Usage: bash run_all_cli_tests.sh [--tool aryo|artifact|ctl|matrix|all] [--verbose]
# ==============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL="all"
export CLI_TEST_VERBOSE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tool|-t) TOOL="$2"; shift 2 ;;
        --verbose|-v) export CLI_TEST_VERBOSE=1; shift ;;
        -h|--help)
            echo "Usage: bash $0 [--tool aryo|artifact|ctl|matrix|all] [--verbose]"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

SUITES=()
case "$TOOL" in
    aryo)     SUITES=("01_test_aryo_commands.sh") ;;
    artifact) SUITES=("02_test_sentinel_artifact_commands.sh") ;;
    ctl)      SUITES=("03_test_sentinel_ctl_commands.sh") ;;
    matrix)   SUITES=("04_test_sentinel_matrix_commands.sh") ;;
    all)      SUITES=("01_test_aryo_commands.sh" "02_test_sentinel_artifact_commands.sh" "03_test_sentinel_ctl_commands.sh" "04_test_sentinel_matrix_commands.sh") ;;
    *)        echo "[-] Unknown tool '$TOOL'. Use: aryo, artifact, ctl, matrix, or all."; exit 1 ;;
esac

OVERALL_RC=0
START_TS=$(date +%s)

for s in "${SUITES[@]}"; do
    bash "$SCRIPT_DIR/$s" || OVERALL_RC=1
done

ELAPSED=$(( $(date +%s) - START_TS ))
echo -e "\n\033[1;36m================================================================================\033[0m"
if [[ "$OVERALL_RC" -eq 0 ]]; then
    echo -e "\033[1;32m  [ALL PASSED] CLI ONE-BY-ONE VERIFICATION COMPLETE in ${ELAPSED}s!\033[0m"
else
    echo -e "\033[1;31m  [FAILURES DETECTED] Review failed command(s) above (${ELAPSED}s).\033[0m"
fi
echo -e "\033[1;36m================================================================================\033[0m"
exit "$OVERALL_RC"
