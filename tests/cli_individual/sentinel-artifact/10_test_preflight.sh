#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_preflight"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

sentinel-artifact keygen "$SANDBOX/work/dev" >/dev/null
sentinel-artifact new preflight_rule lua >/dev/null
sentinel-artifact pack preflight_rule "$SANDBOX/work/dev_private.pem" >/dev/null

test_command_assert \
    "sentinel-artifact test <file.spkg>" \
    "Execute in-sandbox pre-flight threat assertion against embedded preflight_frame.bin vector." \
    0 \
    "PRE-FLIGHT PASS.*KERNEL_DROP" \
    "sentinel-artifact test preflight_rule/preflight_rule.spkg"