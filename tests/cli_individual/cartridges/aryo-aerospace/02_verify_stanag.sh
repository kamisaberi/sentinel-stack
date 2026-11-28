#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aero_stanag"

ensure_scenario_loaded "16_nato_stanag_4586_filter"

test_command_assert \
    "aryo aerospace verify-stanag" \
    "Validate NATO STANAG 4586 UAV telecommand gate against live 16_nato_stanag_4586_filter digital twin." \
    0 \
    "STANAG|4586|PASS|REJECT|DROP|OK" \
    "aryo aerospace verify-stanag"