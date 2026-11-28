#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_down"

aryo vision vision-up >/dev/null 2>&1 || true

test_command_assert \
    "aryo vision vision-down" \
    "Cleanly dismantle the vision_edge_grid simulation mesh and release its Docker subnets." \
    0 \
    "Removed|dismantled|down|Stopped|Teardown|matrix|OK" \
    "aryo vision vision-down"