#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_check"

ensure_scenario_loaded "05_drinking_water_dosing_guard" "ics_guard_dissector_plugin.so"
cd "$SANDBOX/work"
printf 'pipeline:\n  stage_1_reflex:\n    enabled: true\n' > minimal_routes.yaml

test_command_assert \
    "sentinel-ctl check <routes.yaml>" \
    "Audit a ModelRouter YAML DAG specification and verify all local dependencies resolve cleanly." \
    0 \
    "All packages and AI models resolved from cache" \
    "sentinel-ctl check minimal_routes.yaml"