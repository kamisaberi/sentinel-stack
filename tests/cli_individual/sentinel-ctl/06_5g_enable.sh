#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_5g_enable"

ensure_scenario_loaded "21_5g_upf_slicing_governor"

test_command_assert \
    "sentinel-ctl 5g enable lo" \
    "Provision 3GPP URLLC and eMBB network slices into kernel driver on loopback alongside live 5G UPF twin." \
    0 \
    "5G Slicing Guard active in kernel" \
    "sentinel-ctl 5g enable lo"