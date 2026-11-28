#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_trism_safe"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"

test_command_assert \
    "sentinel-ctl trism inspect (benign SCADA query -> exit 0)" \
    "Verify a legitimate operator query about water dosing telemetry is permitted by TrismFirewall." \
    0 \
    "PERMIT - SAFE INTENT" \
    "sentinel-ctl trism inspect --prompt 'Summarize average chlorine dosing flow over the last 4 hours.'"