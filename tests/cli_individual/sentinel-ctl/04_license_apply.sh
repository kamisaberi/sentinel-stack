#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_lic_apply"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/ssfs"
printf '{"tier":"ENTERPRISE","max_nodes":100,"expires":"2030-12-31"}\n' > "$SANDBOX/work/test_ent.lic"

test_command_assert \
    "sentinel-ctl license apply <file.lic>" \
    "Install a commercial license into isolated SSFS Config store (cleaned up automatically on exit)." \
    0 \
    "Successfully applied commercial license" \
    "SENTINEL_ROOT=\"$SANDBOX/ssfs\" sentinel-ctl license apply \"$SANDBOX/work/test_ent.lic\" && test -f \"$SANDBOX/ssfs/config/license.lic\""