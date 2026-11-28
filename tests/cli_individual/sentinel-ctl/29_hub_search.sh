#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_hub_search"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl hub search modbus --type package" \
    "Search Hub catalog (with offline-resilient fallback) for Modbus protection packages." \
    0 \
    "modbus_guard" \
    "sentinel-ctl hub search modbus --type package"