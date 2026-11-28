#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_5g_status"

ensure_scenario_loaded "21_5g_upf_slicing_governor"

test_command_assert \
    "sentinel-ctl 5g status" \
    "Inspect 3GPP 5G/6G N3 GTP-U slice TEIDs (URLLC/eMBB) and drop telemetry alongside live 21_5g_upf_slicing_governor twin." \
    0 \
    "5G/6G SLICE TELEMETRY" \
    "sentinel-ctl 5g status"