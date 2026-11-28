#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_up"

cleanup_vision() {
    if [[ "$KEEP_UP" -eq 0 ]]; then
        aryo vision vision-down >/dev/null 2>&1 || true
    fi
    cleanup_all
}
trap cleanup_vision EXIT

test_command_assert \
    "aryo vision vision-up" \
    "Deploy the vision_edge_grid simulation mesh via aryo-vision and verify live launch." \
    0 \
    "LIVE|Started|Healthy|vision|Running|Done|matrix" \
    "aryo vision vision-up"