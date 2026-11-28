#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_airgap"

ensure_scenario_loaded "21_5g_upf_slicing_governor"

test_command_assert \
    "aryo net airgap-status" \
    "Inspect real-time 5G slice air-gap latch state while 21_5g_upf_slicing_governor is active." \
    0 \
    "AIRGAP|LATCH|ARMED|Tripped|NO|STATUS|PASS" \
    "aryo net airgap-status"