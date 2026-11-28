#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_cache_export"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/cache/models"
printf 'DUMMY_ONNX_MODEL' > "$SANDBOX/cache/models/water_ae_int8.onnx"

test_command_assert \
    "sentinel-ctl cache export <out.tar.gz>" \
    "Export local asset cache into an air-gapped USB sneakernet bundle inside sandbox." \
    0 \
    "Successfully exported air-gapped cache bundle" \
    "SENTINEL_CACHE_DIR=\"$SANDBOX/cache\" sentinel-ctl cache export \"$SANDBOX/work/usb_cache.tar.gz\" && test -f \"$SANDBOX/work/usb_cache.tar.gz\""