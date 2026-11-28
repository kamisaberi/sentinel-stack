#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_service"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo service status sentinel" \
    "Inspect blackbox-sentinel systemd service unit status via aryo service wrapper." \
    0 \
    "blackbox-sentinel|Loaded:|Active:|could not be found" \
    "aryo service status sentinel"