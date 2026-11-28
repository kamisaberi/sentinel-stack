#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "net_desc"

ensure_scenario_loaded "21_5g_upf_slicing_governor"

test_command_assert \
    "aryo-net --plugin-desc" \
    "Verify dynamic plugin discovery metadata string emitted by aryo-net alongside live 5G UPF twin." \
    0 \
    "net|5G|GTP|GOOSE|ITCH|PQC" \
    "aryo-net --plugin-desc"