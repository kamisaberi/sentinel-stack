#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_keygen"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-artifact keygen" \
    "Generate an Ed25519 developer signing keypair alongside the live 05_drinking_water_dosing_guard twin." \
    0 \
    "Generated Ed25519 Keypair" \
    "sentinel-artifact keygen \"$SANDBOX/work/water_dev\" && test -f \"$SANDBOX/work/water_dev_private.pem\" && test -f \"$SANDBOX/work/water_dev_public.pem\""