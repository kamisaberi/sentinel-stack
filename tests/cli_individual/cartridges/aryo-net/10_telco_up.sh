#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_telco_up"

cleanup_telco() {
    if [[ "$KEEP_UP" -eq 0 ]]; then
        aryo net telco-down >/dev/null 2>&1 || true
    fi
    cleanup_all
}
trap cleanup_telco EXIT

test_command_assert \
    "aryo net telco-up" \
    "Deploy the telco_5g_fintech_grid simulation mesh via aryo-net and verify live launch." \
    0 \
    "LIVE|Started|Healthy|telco|Running|Done|matrix" \
    "aryo net telco-up"