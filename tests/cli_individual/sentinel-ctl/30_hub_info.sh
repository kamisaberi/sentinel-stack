#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_hub_info"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl hub info package modbus_guard" \
    "Preview cloud manifest endpoint, cryptographic root, and compliance invariants without downloading." \
    0 \
    "CLOUD ASSET INSPECTION: modbus_guard" \
    "sentinel-ctl hub info package modbus_guard"