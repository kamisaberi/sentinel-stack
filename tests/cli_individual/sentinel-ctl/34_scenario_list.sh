#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_scen_list"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl scenario list" \
    "List cached scenario archives and all 50+ staged SSFS catalog scenarios." \
    0 \
    "05_drinking_water_dosing_guard" \
    "sentinel-ctl scenario list"