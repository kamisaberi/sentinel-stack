#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_sbom_stat"

ensure_scenario_loaded "23_airgapped_cwpp_host_integrity"
mkdir -p "$SANDBOX/ssfs"
SENTINEL_ROOT="$SANDBOX/ssfs" sentinel-ctl sbom generate >/dev/null

test_command_assert \
    "sentinel-ctl sbom status" \
    "Audit Live-SBOM manifest presence and W^X memory integrity status alongside live CWPP twin." \
    0 \
    "ARYORITHM LIVE-SBOM: RUNTIME MEMORY INTEGRITY STATUS" \
    "SENTINEL_ROOT=\"$SANDBOX/ssfs\" sentinel-ctl sbom status"