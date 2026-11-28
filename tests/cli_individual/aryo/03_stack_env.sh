#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_stack_env"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo stack env" \
    "Audit host kernel version, /opt/sentinel-stack/venv installation, and central asset cache availability." \
    0 \
    "Auditing Sentinel-Stack Environment" \
    "aryo stack env"