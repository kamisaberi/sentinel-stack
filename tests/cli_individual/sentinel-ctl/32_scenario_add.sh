#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_scen_add"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
mkdir -p "$SANDBOX/ssfs"
cd "$SANDBOX/work"
printf 'ONNX_DUMMY' > pump_ae_int8.onnx
SENTINEL_ROOT="$SANDBOX/ssfs" sentinel-ctl scenario new water_add_twin --sector WATER_UTILITY >/dev/null

test_command_assert \
    "sentinel-ctl scenario add <slug> <asset> --embed" \
    "Embed an ONNX model into a scaffolded scenario and synchronize its manifest.json dependencies." \
    0 \
    "EMBEDDED.*pump_ae_int8.onnx" \
    "SENTINEL_ROOT=\"$SANDBOX/ssfs\" sentinel-ctl scenario add water_add_twin pump_ae_int8.onnx --embed && test -f \"$SANDBOX/ssfs/scenarios/catalog/water_add_twin/models/pump_ae_int8.onnx\""