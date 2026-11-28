#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_grid_status"

ensure_scenario_loaded "01_substation_busbar_trip" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo ics grid-status" \
    "Inspect live container status of the ICS digital twin mesh while 01_substation_busbar_trip is running." \
    0 \
    "matrix|NAMES|Up|STATUS|01_substation" \
    "aryo ics grid-status"