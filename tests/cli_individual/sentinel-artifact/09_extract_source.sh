#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "art_extract"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"

sentinel-artifact keygen "$SANDBOX/work/dev" >/dev/null
sentinel-artifact new audit_rule lua >/dev/null
sentinel-artifact pack audit_rule "$SANDBOX/work/dev_private.pem" >/dev/null

test_command_assert \
    "sentinel-artifact extract-source <file.spkg> <out>" \
    "Extract auditable LuaJIT source code from a sealed .spkg container alongside live ICS twin." \
    0 \
    "Extracted auditable source code" \
    "sentinel-artifact extract-source audit_rule/audit_rule.spkg extracted_audit.lua && grep -q 'Rule.inspect' extracted_audit.lua"