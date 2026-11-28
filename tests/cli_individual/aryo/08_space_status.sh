#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aryo_space"

ensure_scenario_loaded "14_leo_satcom_downlink_guard"

test_command_assert \
    "aryo space status" \
    "Verify orbital CCSDS/STANAG space telemetry status alongside live 14_leo_satcom_downlink_guard twin." \
    0 \
    "CCSDS|SPACE|STANAG|APID|STATUS|PASS|OK" \
    "aryo space status"