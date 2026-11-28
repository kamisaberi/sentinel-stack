#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_oran"

ensure_scenario_loaded "22_oran_near_rt_ric_governor"

test_command_assert \
    "aryo net verify-oran" \
    "Verify O-RAN Near-RT RIC E2AP rogue xApp control blocking against live 22_oran_near_rt_ric_governor twin." \
    0 \
    "ORAN|O-RAN|E2AP|xApp|PASS|REJECT|DROP" \
    "aryo net verify-oran"