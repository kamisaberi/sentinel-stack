#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_bench"

ensure_scenario_loaded "21_5g_upf_slicing_governor"

test_command_assert \
    "aryo net bench" \
    "Run 100,000-sample 5G GTP-U slice decapsulation benchmark (< 120 ns SLA) alongside live 21_5g_upf_slicing_governor twin." \
    0 \
    "ns|latency|PASS|mean" \
    "aryo net bench"