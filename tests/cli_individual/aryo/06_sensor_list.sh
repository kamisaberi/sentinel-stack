#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_sensor"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo sensor list --limit 5" \
    "Verify aryo delegates sensor catalog queries cleanly to sentinel-matrix/tools/sensor_ctl.py." \
    0 \
    "ARYORITHM MASTER SENSOR CATALOG" \
    "aryo sensor list --limit 5"