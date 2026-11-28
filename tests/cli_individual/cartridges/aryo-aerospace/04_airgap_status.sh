#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aero_airgap"

ensure_scenario_loaded "16_nato_stanag_4586_filter"

test_command_assert \
    "aryo aerospace airgap-status" \
    "Inspect aerospace actuator air-gap tripwire latch state while 16_nato_stanag_4586_filter is active." \
    0 \
    "AIRGAP|LATCH|ARMED|Tripped|NO|STATUS|PASS" \
    "aryo aerospace airgap-status"