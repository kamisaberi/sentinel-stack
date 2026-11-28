#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_mdl_pack"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"
printf 'ONNX_WATER_AE_INT8_TEST_PAYLOAD' > water_ae_int8.onnx

test_command_assert \
    "sentinel-ctl model pack <model.onnx>" \
    "Auto-detect INT8 precision from filename and generate Hub companion manifests for an ONNX model." \
    0 \
    "Successfully generated model companion manifest" \
    "sentinel-ctl model pack water_ae_int8.onnx --domain SCADA_ICS && test -f water_ae_int8.onnx.manifest.json && grep -q '\"precision\": \"INT8\"' water_ae_int8.onnx.manifest.json"