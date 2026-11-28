#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_modbus"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo ics verify-modbus" \
    "Verify Modbus TCP read/write interlock against live 05_drinking_water_dosing_guard digital twin." \
    0 \
    "MODBUS|DROP|BLOCK|PASS|ALLOW" \
    "aryo ics verify-modbus"