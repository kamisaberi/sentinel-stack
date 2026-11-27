#!/usr/bin/env bash
# ==============================================================================
# SUITE 01: MASTER UMBRELLA CLI (aryo v2.5.0) — ONE-BY-ONE COMMAND VERIFICATION
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib_cli_test.sh"
init_sandbox "cli_aryo"

log_section "SUITE 01: ARYO MASTER UMBRELLA CLI (Tier 4 Dispatcher)"

run_cli_test "aryo --version" \
    "Display Aryorithm CLI banner, version (v2.5.0), and corporate/Hub URLs." \
    0 "aryo --version"

run_cli_test "aryo --help" \
    "Display all 18 core domains, 5 platform cartridges, and dynamically discovered aryo-* plugins." \
    0 "aryo --help"

for dom in appliance stack hub sensor package model dataset pcap scenario fleet forge lab matrix cache system 5g sbom space trism blueprint; do
    run_cli_test "aryo $dom --help" \
        "Display built-in operational manual and examples for the '$dom' domain." \
        0 "aryo $dom --help"
done

run_cli_test "aryo status" \
    "Delegate to sentinel-ctl status to audit licensing, TPM 2.0 root, eBPF maps, extensions, and DAG." \
    0 "aryo status"

run_cli_test "aryo stack env" \
    "Audit host kernel version, /opt/sentinel-stack/venv, and central cache availability." \
    0 "aryo stack env"

run_cli_test "aryo scenario list-recipes" \
    "Enumerate all 50 turnkey real-world scenario provisioning scripts in sentinel-stack." \
    0 "aryo scenario list-recipes | grep -q '05_drinking_water_dosing_guard'"

run_cli_test "aryo sensor list --limit 5" \
    "Delegate to sentinel-matrix/tools/sensor_ctl.py to list cataloged industrial sensors." \
    0 "aryo sensor list --limit 5"

run_cli_test "aryo visibility --help" \
    "Display usage for promoting/demoting Hub artifact visibility (public/private)." \
    0 "aryo visibility --help"

# Verify dynamic discovery of all 5 Tier-2 domain cartridge plugins
for plugin in ics aerospace net motion vision; do
    if command -v "aryo-${plugin}" >/dev/null 2>&1; then
        run_cli_test "aryo $plugin --help" \
            "Dynamically dispatch to installed Tier-2 domain cartridge plugin (aryo-${plugin})." \
            0 "aryo $plugin --help"
    else
        skip_cli_test "aryo $plugin --help" \
            "Dynamically dispatch to Tier-2 plugin aryo-${plugin}." \
            "Binary aryo-${plugin} not found in PATH"
    fi
done

run_cli_test "aryo unknown_domain (error handling)" \
    "Verify unknown domains fail cleanly with exit code 1." \
    1 "aryo __nonexistent_domain__"

print_suite_summary "01_aryo"
