#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_new_cpp"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

test_command_assert \
    "sentinel-artifact new <name> cpp" \
    "Scaffold a Tier A Native C++20 dissector project (< 120 ns SLA) alongside live ICS twin." \
    0 \
    "Successfully scaffolded artifact project" \
    "sentinel-artifact new water_dosing_cpp cpp && test -f water_dosing_cpp/CMakeLists.txt && test -f water_dosing_cpp/src/plugin.cpp"