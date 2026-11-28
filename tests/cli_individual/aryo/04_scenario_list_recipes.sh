#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_recipes"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo scenario list-recipes" \
    "Enumerate all 50 turnkey real-world scenario provisioning scripts in sentinel-stack." \
    0 \
    "50_subway_platform_crowd_eye" \
    "aryo scenario list-recipes"