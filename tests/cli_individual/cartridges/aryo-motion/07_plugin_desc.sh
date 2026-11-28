#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_desc"

ensure_scenario_loaded "28_cobot_iso13849_governor"

test_command_assert \
    "aryo-motion --plugin-desc" \
    "Verify dynamic plugin discovery metadata string emitted by aryo-motion alongside live cobot twin." \
    0 \
    "motion|Robotics|EtherCAT|CAN|CBF" \
    "aryo-motion --plugin-desc"