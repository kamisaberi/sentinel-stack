#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aero_ccsds"

ensure_scenario_loaded "14_leo_satcom_downlink_guard"

test_command_assert \
    "aryo aerospace verify-ccsds" \
    "Validate CCSDS 132/133 space packet telecommand frame verification against live 14_leo_satcom_downlink_guard twin." \
    0 \
    "CCSDS|133|132|PASS|REJECT|DROP|OK" \
    "aryo aerospace verify-ccsds"