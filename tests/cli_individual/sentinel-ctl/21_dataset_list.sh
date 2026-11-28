#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_ds_list"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl dataset list" \
    "Enumerate locally cached and staged zero-copy .slab binary telemetry datasets." \
    0 \
    "LOCAL ASSET REPOSITORY: datasets" \
    "sentinel-ctl dataset list"