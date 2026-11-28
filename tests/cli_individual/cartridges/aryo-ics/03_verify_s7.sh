#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_s7"

ensure_scenario_loaded "09_smart_factory_profinet_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "aryo ics verify-s7" \
    "Verify Siemens S7Comm CPU STOP (0x29) interception against live 09_smart_factory_profinet_guard twin." \
    0 \
    "S7|0x29|STOP|DROP|BLOCK|PASS" \
    "aryo ics verify-s7"