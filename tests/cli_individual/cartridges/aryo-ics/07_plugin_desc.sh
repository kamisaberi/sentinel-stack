#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_desc"

ensure_scenario_loaded "01_substation_busbar_trip" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo-ics --plugin-desc" \
    "Verify dynamic plugin discovery metadata string emitted by aryo-ics alongside live ICS twin." \
    0 \
    "ics|SCADA|Industrial|Modbus|OT" \
    "aryo-ics --plugin-desc"