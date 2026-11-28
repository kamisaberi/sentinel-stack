#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_matrix"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo matrix scenario status --name 05_drinking_water_dosing_guard" \
    "Inspect live matrix scenario containers via aryo matrix umbrella delegation." \
    0 \
    "matrix-nexus|matrix-edge-01" \
    "aryo matrix scenario status --name 05_drinking_water_dosing_guard"