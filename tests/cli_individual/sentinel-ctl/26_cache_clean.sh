#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_cache_clean"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/cache/models"
printf 'DUMMY_ONNX_MODEL' > "$SANDBOX/cache/models/water_ae_int8.onnx"

test_command_assert \
    "sentinel-ctl cache clean" \
    "Purge the isolated sandbox asset cache directory cleanly without affecting host cache." \
    0 \
    "Cleared cache directory" \
    "SENTINEL_CACHE_DIR=\"$SANDBOX/cache\" sentinel-ctl cache clean && test ! -d \"$SANDBOX/cache\""