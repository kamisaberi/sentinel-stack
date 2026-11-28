#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "mat_status"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "scenario_engine.py status --name 05_drinking_water_dosing_guard" \
    "Inspect live container health and exposed ports for a running SSFS scenario workspace." \
    0 \
    "matrix-nexus|matrix-edge-01-05_drinking_water_dosing_guard" \
    "python3 /home/kami/sentinel-matrix/tools/scenario_engine.py status --name 05_drinking_water_dosing_guard"