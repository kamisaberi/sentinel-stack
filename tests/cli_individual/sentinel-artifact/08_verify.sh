#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_verify"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

sentinel-artifact keygen "$SANDBOX/work/dev" >/dev/null
sentinel-artifact new verify_rule lua >/dev/null
sentinel-artifact pack verify_rule "$SANDBOX/work/dev_private.pem" >/dev/null

test_command_assert \
    "sentinel-artifact verify <pub_key> <file.spkg>" \
    "Cryptographically verify the 4-way SHA-256 Merkle Ed25519 signature of a sealed .spkg container." \
    0 \
    "VERIFIED.*AUTHENTIC" \
    "sentinel-artifact verify \"$SANDBOX/work/dev_public.pem\" verify_rule/verify_rule.spkg"