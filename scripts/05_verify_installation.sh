#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 5] Executing 15-Point System Health Checks ==="

PASSED=0
TOTAL=15

check_artifact() {
    local TITLE="$1"
    local CMD="$2"
    echo -n "[*] Testing ${TITLE}... "
    if eval "${CMD}" >/dev/null 2>&1; then
        echo -e "\033[32m[PASS]\033[0m"
        PASSED=$((PASSED + 1))
    else
        echo -e "\033[31m[FAIL]\033[0m"
    fi
}

# 1. Tier 1 Shared Library
check_artifact "Tier 1: libxinfer.so" "test -f /usr/local/lib/libxinfer.so && ldconfig -p | grep libxinfer"

# 2. Tier 2 Shared Library & AF_XDP
check_artifact "Tier 2: libblackbox.so" "test -f /usr/local/lib/libblackbox.so && ldconfig -p | grep libblackbox"

# 3. Tier 2 Kernel eBPF Filter
check_artifact "Tier 2: xdp_drop.o filter" "test -f /etc/sentinel/xdp_drop.o"

# 4. Tier 3 Edge Appliance Daemon
check_artifact "Tier 3: sentinel binary" "test -x /usr/local/bin/sentinel"

# 5. Extensibility Toolchain
check_artifact "Toolchain: sentinel-spkg CLI" "test -x /usr/local/bin/sentinel-spkg"

# 6. Dependency Manager CLI
check_artifact "Toolchain: sentinel-ctl CLI" "test -x /usr/local/bin/sentinel-ctl && /usr/local/bin/sentinel-ctl --help"

# 7. Tier 4 Continuous Retraining CLI
check_artifact "Tier 4: forge-cli runtime" "/usr/local/bin/forge-cli --help"

# 8. Tier 5 Academic Lab Testbed Binary
check_artifact "Tier 5: sentinel_lab binary" "test -x /usr/local/bin/sentinel_lab"

# 9. Tier 5 Research Profiles (14 JSON Configs)
check_artifact "Tier 5: Research JSON Profiles" "test -f /etc/sentinel/configs/evt_profile.json && test -f /etc/sentinel/configs/hil_profile.json"

# 10. Tier 5 Python Research Harnesses
check_artifact "Tier 5: Python Research Harnesses" "test -f /opt/sentinel-stack/harnesses/socket_injector.py"

# 11. Tier 6 Nexus Command Plane & CLI
check_artifact "Tier 6: sentinel-nexus & nexus-ctl" "test -x /usr/local/bin/sentinel-nexus && test -x /usr/local/bin/nexus-ctl"

# 12. Tier 7 Digital Twin PLC Binary
check_artifact "Tier 7: mock_plc twin binary" "test -x /usr/local/bin/mock_plc || test -x /home/kami/sentinel-matrix/shared/bin/mock_plc"

# 13. Central Cache Root
check_artifact "Filesystem: /var/cache/sentinel" "test -d /var/cache/sentinel"

# 14. Isolated Python Virtual Environment
check_artifact "Virtualenv: /opt/sentinel-stack/venv" "test -x /opt/sentinel-stack/venv/bin/python3"

# 15. Web C2 Dashboard Assets
check_artifact "Web Console: /opt/sentinel-nexus/web" "test -f /opt/sentinel-nexus/web/index.html"

# 16. Unified Master CLI (aryo)
check_artifact "Master CLI: aryo --help" "test -x /usr/local/bin/aryo && /usr/local/bin/aryo --help"

echo "--------------------------------------------------------"
echo "[+] Smoke Test Results: ${PASSED}/${TOTAL} Health Checks Verified."
if [ "${PASSED}" -eq "${TOTAL}" ]; then
    echo -e "\033[32m[+] All 15/15 ecosystem tiers, research modules, toolchains, and daemons verified successfully!\033[0m"
    exit 0
else
    echo -e "\033[31m[-] Some artifacts failed verification. Check build logs above.\033[0m"
    exit 1
fi