#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aero_swarm_down"

aryo aerospace sim-swarm >/dev/null 2>&1 || true

test_command_assert \
    "aryo aerospace sim-swarm-down" \
    "Cleanly dismantle the Autonomous UAV Swarm simulation mesh and release its Docker subnets." \
    0 \
    "Removed|dismantled|down|Stopped|Teardown|matrix|OK" \
    "aryo aerospace sim-swarm-down"