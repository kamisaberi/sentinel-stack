#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_pub_guard"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-artifact publish (nonexistent file safety guard)" \
    "Confirm publish validates local file existence and aborts cleanly (exit 1) before network transmission." \
    1 \
    "Artifact file to publish not found" \
    "sentinel-artifact publish \"$SANDBOX/work/__missing__.spkg\" --token dummy"