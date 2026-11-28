#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_trism_stat"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl trism status" \
    "Inspect 3-stage AI TRiSM LLM firewall SLA (Aho-Corasick, INT8 Semantic, Tool-Call Governor)." \
    0 \
    "AI TRiSM LLM FIREWALL" \
    "sentinel-ctl trism status"