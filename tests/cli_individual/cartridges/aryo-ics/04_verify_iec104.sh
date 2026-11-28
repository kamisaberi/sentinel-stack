#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_iec104"

ensure_scenario_loaded "01_substation_busbar_trip" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo ics verify-iec104" \
    "Verify IEC 60870-5-104 breaker trip (COT=6) interception against live 01_substation_busbar_trip twin." \
    0 \
    "IEC|104|COT|DROP|BLOCK|PASS" \
    "aryo ics verify-iec104"