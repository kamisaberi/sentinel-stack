#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_lic_inspect"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
printf '{"tier":"ENTERPRISE","max_nodes":100,"expires":"2030-12-31"}\n' > "$SANDBOX/work/test_ent.lic"

test_command_assert \
    "sentinel-ctl license inspect <file.lic>" \
    "Inspect entitlements and metadata inside a commercial Sentinel license file." \
    0 \
    "SENTINEL COMMERCIAL LICENSE INSPECTION" \
    "sentinel-ctl license inspect \"$SANDBOX/work/test_ent.lic\""