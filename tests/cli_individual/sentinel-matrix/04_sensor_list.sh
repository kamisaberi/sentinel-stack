#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "mat_sensor_list"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sensor_ctl.py list --search pressure --limit 10" \
    "Query and filter the 570-sensor industrial catalog alongside live 05_drinking_water_dosing_guard twin." \
    0 \
    "ARYORITHM MASTER SENSOR CATALOG" \
    "python3 /home/kami/sentinel-matrix/tools/sensor_ctl.py list --search pressure --limit 10"