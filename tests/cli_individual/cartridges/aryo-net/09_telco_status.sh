#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_telco_status"

ensure_scenario_loaded "21_5g_upf_slicing_governor"

test_command_assert \
    "aryo net telco-status" \
    "Inspect running 5G/FinTech simulation containers while 21_5g_upf_slicing_governor is active." \
    0 \
    "matrix|NAMES|Up|STATUS|21_5g" \
    "aryo net telco-status"