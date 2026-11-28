#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_hw_status"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl hardware status" \
    "Inspect physical hardware profile, TPM 2.0 attestation state, DMI UUID, and silicon binding token." \
    0 \
    "PHYSICAL HARDWARE PROVISIONING" \
    "sentinel-ctl hardware status"