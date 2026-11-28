#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_ethercat"

ensure_scenario_loaded "28_cobot_iso13849_governor"

test_command_assert \
    "aryo motion verify-ethercat" \
    "Verify Non-IP L2 EtherCAT (0x88A4) cobot joint surge clamp against live 28_cobot_iso13849_governor twin." \
    0 \
    "EtherCAT|0x88A4|SURGE|CLAMP|PASS|REJECT|DROP" \
    "aryo motion verify-ethercat"