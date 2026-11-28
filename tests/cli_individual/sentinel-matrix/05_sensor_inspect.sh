#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "mat_sensor_insp"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

FIRST_SENSOR=$(find /home/kami/sentinel-matrix/catalogs/sensors -name 's*.yaml' | sort | head -n1 | xargs -r basename | sed 's/\.yaml$//')

test_command_assert \
    "sensor_ctl.py inspect <sensor_id>" \
    "Inspect vendor, wire protocol, physics ODE engine, holding registers, and chaos hooks for a cataloged sensor." \
    0 \
    "SENSOR INSPECTION" \
    "python3 /home/kami/sentinel-matrix/tools/sensor_ctl.py inspect \"$FIRST_SENSOR\""