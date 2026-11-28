#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_cobot_status"

ensure_scenario_loaded "28_cobot_iso13849_governor"

test_command_assert \
    "aryo motion cobot-status" \
    "Inspect running robotics simulation containers while 28_cobot_iso13849_governor is active." \
    0 \
    "matrix|NAMES|Up|STATUS|28_cobot" \
    "aryo motion cobot-status"