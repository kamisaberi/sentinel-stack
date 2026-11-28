#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_bench"

ensure_scenario_loaded "28_cobot_iso13849_governor"

test_command_assert \
    "aryo motion bench" \
    "Run 100,000-sample EtherCAT/CAN-FD motion benchmark (< 120 ns SLA) alongside live 28_cobot_iso13849_governor twin." \
    0 \
    "ns|latency|PASS|mean" \
    "aryo motion bench"