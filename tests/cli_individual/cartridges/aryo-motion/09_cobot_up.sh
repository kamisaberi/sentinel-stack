#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_cobot_up"

cleanup_cobot() {
    if [[ "$KEEP_UP" -eq 0 ]]; then
        aryo motion cobot-down >/dev/null 2>&1 || true
    fi
    cleanup_all
}
trap cleanup_cobot EXIT

test_command_assert \
    "aryo motion cobot-up" \
    "Deploy the robotics_can_ethercat_grid simulation mesh via aryo-motion and verify live launch." \
    0 \
    "LIVE|Started|Healthy|robotics|cobot|Running|Done|matrix" \
    "aryo motion cobot-up"