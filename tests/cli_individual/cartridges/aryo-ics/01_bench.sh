#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_bench"

ensure_scenario_loaded "01_substation_busbar_trip" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo ics bench" \
    "Run 100,000-sample ICS deterministic latency benchmark alongside live 01_substation_busbar_trip twin." \
    0 \
    "ns|latency|PASS|mean" \
    "aryo ics bench"