#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_cbf"

ensure_scenario_loaded "03_bess_thermal_runaway" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo ics verify-cbf" \
    "Verify Nagumo CBF thermal safety gate against live 03_bess_thermal_runaway digital twin." \
    0 \
    "CBF|Nagumo|thermal|SAFE|DROP|PASS" \
    "aryo ics verify-cbf"