#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_cache_list"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/cache/models"
printf 'DUMMY_ONNX_MODEL' > "$SANDBOX/cache/models/water_ae_int8.onnx"

test_command_assert \
    "sentinel-ctl cache list" \
    "Enumerate all assets and byte footprints inside the isolated SSFS asset cache." \
    0 \
    "water_ae_int8.onnx" \
    "SENTINEL_CACHE_DIR=\"$SANDBOX/cache\" sentinel-ctl cache list"