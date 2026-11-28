#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_gtpu"

ensure_scenario_loaded "21_5g_upf_slicing_governor"

test_command_assert \
    "aryo net verify-gtpu" \
    "Verify 3GPP GTP-U URLLC vs eMBB slice-hopping enforcement against live 21_5g_upf_slicing_governor twin." \
    0 \
    "GTP|SLICE|URLLC|PASS|REJECT|DROP" \
    "aryo net verify-gtpu"