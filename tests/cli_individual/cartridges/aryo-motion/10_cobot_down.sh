#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_cobot_down"

aryo motion cobot-up >/dev/null 2>&1 || true

test_command_assert \
    "aryo motion cobot-down" \
    "Cleanly dismantle the robotics_can_ethercat_grid simulation mesh and release its Docker subnets." \
    0 \
    "Removed|dismantled|down|Stopped|Teardown|matrix|OK" \
    "aryo motion cobot-down"