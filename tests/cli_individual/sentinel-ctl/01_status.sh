#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_status"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl status" \
    "Audit appliance licensing, TPM 2.0 / DMI root, eBPF map state, SSFS cache, extensions, and DAG alongside live twin." \
    0 \
    "BLACKBOX SENTINEL APPLIANCE STATUS" \
    "sentinel-ctl status"