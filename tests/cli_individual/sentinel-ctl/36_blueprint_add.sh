#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_bp_add"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"
printf 'ONNX_DUMMY' > water_ae_int8.onnx
sentinel-ctl blueprint new sub_water_02 --site WaterPlant-North-02 >/dev/null

test_command_assert \
    "sentinel-ctl blueprint add <dir> <asset> --embed" \
    "Embed an ONNX model into a production site blueprint and synchronize manifest.json." \
    0 \
    "EMBEDDED.*water_ae_int8.onnx" \
    "sentinel-ctl blueprint add sub_water_02 water_ae_int8.onnx --embed && test -f sub_water_02/models/water_ae_int8.onnx"