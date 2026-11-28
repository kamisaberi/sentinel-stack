#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "comp_sfs"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
printf 'SSFS_CAS_TEST_PAYLOAD' > "$SANDBOX/work/cas_probe.bin"

test_command_assert \
    "sfs status && sfs resolve && sfs cas-hash" \
    "Verify Tier-0 Sovereign Sentinel Filesystem anchor roots, pack:// URI resolution, and SHA-256 CAS hashing." \
    0 \
    "/opt/sentinel/packs/ics-guard/web|ics-guard" \
    "sfs status && sfs resolve pack://ics-guard/web && sfs cas-hash \"$SANDBOX/work/cas_probe.bin\""