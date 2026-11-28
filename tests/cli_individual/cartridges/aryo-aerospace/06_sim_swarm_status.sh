#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aero_swarm_status"

ensure_scenario_loaded "16_nato_stanag_4586_filter"

test_command_assert \
    "aryo aerospace sim-swarm-status" \
    "Inspect running UAV swarm simulation containers while 16_nato_stanag_4586_filter is active." \
    0 \
    "matrix|NAMES|Up|STATUS|16_nato" \
    "aryo aerospace sim-swarm-status"