#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_airgap"

ensure_scenario_loaded "01_substation_busbar_trip" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo ics airgap-status" \
    "Inspect live ICS actuator air-gap tripwire latch state while 01_substation_busbar_trip is active." \
    0 \
    "AIRGAP|LATCH|ARMED|STATUS|OK|PASS" \
    "aryo ics airgap-status"