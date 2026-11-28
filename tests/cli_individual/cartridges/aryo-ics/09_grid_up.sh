#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ics_grid_up"

cleanup_grid() {
    if [[ "$KEEP_UP" -eq 0 ]]; then
        aryo ics grid-down >/dev/null 2>&1 || true
    fi
    cleanup_all
}
trap cleanup_grid EXIT

test_command_assert \
    "aryo ics grid-up" \
    "Deploy the Production Master Grid digital twin mesh via aryo-ics and verify live launch." \
    0 \
    "LIVE|Started|Healthy|grid|Running|Done|matrix" \
    "aryo ics grid-up"