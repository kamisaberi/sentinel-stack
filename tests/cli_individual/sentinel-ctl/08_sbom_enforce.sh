#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_sbom_enf"

ensure_scenario_loaded "23_airgapped_cwpp_host_integrity"

test_command_assert \
    "sentinel-ctl sbom enforce" \
    "Enroll running daemons into in-kernel eBPF W^X memory protection (< 1.0 us SIGKILL SLA)." \
    0 \
    "Live-SBOM In-Kernel Enforcement Active" \
    "sentinel-ctl sbom enforce"