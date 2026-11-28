#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "vision_rtsp"

ensure_scenario_loaded "36_airgapped_weapon_breach_guard"

test_command_assert \
    "aryo vision verify-rtsp" \
    "Verify air-gapped 4K RTSP/ONVIF stream hijack blocking against live 36_airgapped_weapon_breach_guard twin." \
    0 \
    "RTSP|ONVIF|HIJACK|TEARDOWN|PASS|REJECT|DROP" \
    "aryo vision verify-rtsp"