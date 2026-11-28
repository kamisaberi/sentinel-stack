#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_scen_new"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/ssfs"

test_command_assert \
    "sentinel-ctl scenario new <name> --sector <s>" \
    "Scaffold a turnkey scenario skeleton (manifest.json, scenario.yaml, run_demo.sh) inside isolated SSFS catalog." \
    0 \
    "Successfully scaffolded scenario" \
    "SENTINEL_ROOT=\"$SANDBOX/ssfs\" sentinel-ctl scenario new water_test_twin --sector WATER_UTILITY && test -f \"$SANDBOX/ssfs/scenarios/catalog/water_test_twin/scenario.yaml\""