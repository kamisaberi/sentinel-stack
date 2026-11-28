#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "mat_make_status"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "make -C sentinel-matrix scenario-status" \
    "Verify Sentinel-Matrix Makefile orchestration target reports running 05_drinking_water_dosing_guard containers." \
    0 \
    "matrix-nexus|matrix-edge-01" \
    "make -C /home/kami/sentinel-matrix scenario-status NAME=05_drinking_water_dosing_guard"