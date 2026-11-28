#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_inspect"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

sentinel-artifact keygen "$SANDBOX/work/dev" >/dev/null
sentinel-artifact new inspect_rule lua >/dev/null
sentinel-artifact pack inspect_rule "$SANDBOX/work/dev_private.pem" >/dev/null

test_command_assert \
    "sentinel-artifact inspect <file.spkg>" \
    "Parse binary SpkgHeader (ARYOSPKG), execution tier, section sizes, and embedded manifest." \
    0 \
    "Tier C \(LuaJIT FFI\)" \
    "sentinel-artifact inspect inspect_rule/inspect_rule.spkg"