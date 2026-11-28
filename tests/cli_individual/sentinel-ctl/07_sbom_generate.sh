#!/usr/bin/env bash
source "/home/kami/sentinel-stack/tests/cli_individual/lib_individual_test.sh"
parse_common_flags "$@"
init_sandbox "ctl_sbom_gen"

ensure_scenario_loaded "23_airgapped_cwpp_host_integrity"
mkdir -p "$SANDBOX/ssfs"

test_command_assert \
    "sentinel-ctl sbom generate" \
    "Hash installed ecosystem binaries/libs into CycloneDX 1.6 live_sbom.json inside isolated SSFS sandbox." \
    0 \
    "Successfully generated signed Live-SBOM manifest" \
    "SENTINEL_ROOT=\"$SANDBOX/ssfs\" sentinel-ctl sbom generate && test -f \"$SANDBOX/ssfs/config/live_sbom.json\""