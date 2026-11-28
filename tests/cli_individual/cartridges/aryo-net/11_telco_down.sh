#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_telco_down"

aryo net telco-up >/dev/null 2>&1 || true

test_command_assert \
    "aryo net telco-down" \
    "Cleanly dismantle the telco_5g_fintech_grid simulation mesh and release its Docker subnets." \
    0 \
    "Removed|dismantled|down|Stopped|Teardown|matrix|OK" \
    "aryo net telco-down"