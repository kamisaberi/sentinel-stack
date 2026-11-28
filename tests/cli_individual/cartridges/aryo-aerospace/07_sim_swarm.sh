#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aero_swarm_up"

cleanup_swarm() {
    if [[ "$KEEP_UP" -eq 0 ]]; then
        aryo aerospace sim-swarm-down >/dev/null 2>&1 || true
    fi
    cleanup_all
}
trap cleanup_swarm EXIT

test_command_assert \
    "aryo aerospace sim-swarm" \
    "Deploy the Autonomous UAV Swarm Tactical Defense Twin via aryo-aerospace and verify live launch." \
    0 \
    "LIVE|Started|Healthy|swarm|Running|Done|matrix" \
    "aryo aerospace sim-swarm"