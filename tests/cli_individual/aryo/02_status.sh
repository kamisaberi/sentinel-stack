#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_status"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo status" \
    "Verify aryo delegates status cleanly to sentinel-ctl while 05_drinking_water_dosing_guard is active." \
    0 \
    "BLACKBOX SENTINEL APPLIANCE STATUS" \
    "aryo status"