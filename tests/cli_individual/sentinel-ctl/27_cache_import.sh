#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_cache_import"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/src_cache/models" "$SANDBOX/dst_cache"
printf 'DUMMY_ONNX_MODEL' > "$SANDBOX/src_cache/models/water_ae_int8.onnx"
SENTINEL_CACHE_DIR="$SANDBOX/src_cache" sentinel-ctl cache export "$SANDBOX/work/usb_bundle.tar.gz" >/dev/null

test_command_assert \
    "sentinel-ctl cache import <in.tar.gz>" \
    "Restore an air-gapped USB sneakernet cache bundle into a fresh isolated cache directory." \
    0 \
    "Successfully imported offline cache bundle" \
    "SENTINEL_CACHE_DIR=\"$SANDBOX/dst_cache\" sentinel-ctl cache import \"$SANDBOX/work/usb_bundle.tar.gz\" && test -f \"$SANDBOX/dst_cache/models/water_ae_int8.onnx\""