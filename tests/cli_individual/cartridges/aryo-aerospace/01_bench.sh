#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "aero_bench"

ensure_scenario_loaded "14_leo_satcom_downlink_guard"

test_command_assert \
    "aryo aerospace bench" \
    "Run 100,000-sample deterministic aerospace latency benchmark (< 120 ns SLA) alongside live 14_leo_satcom_downlink_guard twin." \
    0 \
    "ns|latency|PASS|mean" \
    "aryo aerospace bench"