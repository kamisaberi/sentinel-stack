#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_itch"

ensure_scenario_loaded "24_fintech_pretrade_risk_firewall"

test_command_assert \
    "aryo net verify-itch" \
    "Verify NASDAQ ITCH 5.0 pre-trade fat-finger order drop against live 24_fintech_pretrade_risk_firewall twin." \
    0 \
    "ITCH|NASDAQ|COLLAR|FAT|PASS|REJECT|DROP" \
    "aryo net verify-itch"