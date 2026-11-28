#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_sbom_drift"

ensure_scenario_loaded "23_airgapped_cwpp_host_integrity"

test_command_assert \
    "sentinel-ctl sbom test-drift" \
    "Fork a sandboxed child process to validate W^X PROT_EXEC fileless shellcode interception." \
    0 \
    "PASS.*Live-SBOM In-Kernel Engine validated W\^X enforcement" \
    "sentinel-ctl sbom test-drift"