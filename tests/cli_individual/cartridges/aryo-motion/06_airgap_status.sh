#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_airgap"

ensure_scenario_loaded "28_cobot_iso13849_governor"

test_command_assert \
    "aryo motion airgap-status" \
    "Inspect real-time motion air-gap latch state while 28_cobot_iso13849_governor is active." \
    0 \
    "AIRGAP|LATCH|ARMED|Tripped|NO|STATUS|PASS" \
    "aryo motion airgap-status"