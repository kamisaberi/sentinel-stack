#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "motion_shm"

ensure_scenario_loaded "29_amr_3d_pallet_obstacle"

test_command_assert \
    "aryo motion verify-shm" \
    "Verify POSIX ShmRing (MOT1) AMR obstacle collision and brake thermal guard against live 29_amr_3d_pallet_obstacle twin." \
    0 \
    "SHM|MOT1|AMR|OBSTACLE|BRAKE|PASS|REJECT|DROP" \
    "aryo motion verify-shm"