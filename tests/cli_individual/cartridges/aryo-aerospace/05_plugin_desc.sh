#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aero_desc"

ensure_scenario_loaded "14_leo_satcom_downlink_guard"

test_command_assert \
    "aryo-aerospace --plugin-desc" \
    "Verify dynamic plugin discovery metadata string emitted by aryo-aerospace alongside live LEO Satcom twin." \
    0 \
    "aerospace|UAV|CCSDS|STANAG|Space" \
    "aryo-aerospace --plugin-desc"