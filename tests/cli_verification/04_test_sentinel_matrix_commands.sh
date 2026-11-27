#!/usr/bin/env bash
# ==============================================================================
# SUITE 04: SENTINEL-MATRIX (Cyber-Range & Sensor Chaos CLI) — ONE-BY-ONE TESTS
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib_cli_test.sh"
init_sandbox "cli_matrix"

MATRIX_DIR="/home/kami/sentinel-matrix"

log_section "SUITE 04: SENTINEL-MATRIX (Tier 3 Digital Twin & Sensor Chaos)"

run_cli_test "matrix_ctl.sh (help)" \
    "Display matrix-ctl cyber-range controller usage (status, sync-pcaps, scenario, replay)." \
    0 "bash \"$MATRIX_DIR/tools/matrix_ctl.sh\""

run_cli_test "scenario_engine.py --help" \
    "Display Universal Scenario Compiler & Orchestrator subcommands (load, down, status)." \
    0 "python3 \"$MATRIX_DIR/tools/scenario_engine.py\" --help"

run_cli_test "scenario_engine.py status" \
    "Inspect running matrix-* digital twin containers and attached subnets." \
    0 "python3 \"$MATRIX_DIR/tools/scenario_engine.py\" status"

run_cli_test "scenario_engine.py dry-compile (SSFS pack:// URI resolution)" \
    "Verify scenario.yaml -> docker-compose.*.yml compilation and pack:// URI anchoring inside sandbox." \
    0 "python3 -c '
import sys
from pathlib import Path
sys.path.insert(0, \"/home/kami/sentinel-matrix/tools\")
import scenario_engine as se
# Locate any real provisioned scenario.yaml in user catalog
cat_yaml = next(Path(\"/home/kami/.sentinel/scenarios/catalog\").glob(\"05_*/scenario.yaml\"), None)
assert cat_yaml is not None, \"05_drinking_water_dosing_guard/scenario.yaml not found\"
slug, ypath, wdir = se.resolve_scenario_yaml(str(cat_yaml))
out_yml, actual = se.compile_scenario_to_compose(ypath, wdir, slug)
assert out_yml.exists() and out_yml.stat().st_size > 200
print(f\"Compiled {actual} -> {out_yml} ({out_yml.stat().st_size} bytes)\")
'"

run_cli_test "sensor_ctl.py --help" \
    "Display Master Sensor Controller usage (list, inspect, fault)." \
    0 "python3 \"$MATRIX_DIR/tools/sensor_ctl.py\" --help"

run_cli_test "sensor_ctl.py list --limit 10" \
    "Enumerate top 10 numerically sorted industrial sensor archetypes from the 570-sensor catalog." \
    0 "python3 \"$MATRIX_DIR/tools/sensor_ctl.py\" list --limit 10"

run_cli_test "sensor_ctl.py list --search pressure --limit 5" \
    "Filter the 570-sensor catalog by substring query." \
    0 "python3 \"$MATRIX_DIR/tools/sensor_ctl.py\" list --search pressure --limit 5"

run_cli_test "sensor_ctl.py inspect <sensor_id>" \
    "Inspect vendor, protocol, physics engine, Modbus holding registers, and chaos fault hooks." \
    0 "FIRST_ID=\$(find \"$MATRIX_DIR/catalogs/sensors\" -name 's*.yaml' | sort | head -n1 | xargs -r basename | sed 's/\.yaml\$//'); python3 \"$MATRIX_DIR/tools/sensor_ctl.py\" inspect \"\$FIRST_ID\""

run_cli_test "sentinel-matrix Makefile help" \
    "Verify Sentinel-Matrix Makefile orchestration targets (init, build-*, scenario-up/down/status)." \
    0 "make -C \"$MATRIX_DIR\" help"

print_suite_summary "04_sentinel_matrix"
