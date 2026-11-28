#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_lab"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo lab --help" \
    "Verify sentinel-lab 14-D research testbed catalog and dynamic cartridge harness discovery." \
    0 \
    "SENTINEL-LAB: 14-DIMENSIONAL SCIENTIFIC RESEARCH TESTBED" \
    "aryo lab --help"