#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_can"

ensure_scenario_loaded "34_mining_canfd_steering_governor"

test_command_assert \
    "aryo motion verify-can" \
    "Verify SocketCAN / CAN-FD steering and torque override blocking against live 34_mining_canfd_steering_governor twin." \
    0 \
    "CAN|STEER|TORQUE|PASS|REJECT|DROP" \
    "aryo motion verify-can"