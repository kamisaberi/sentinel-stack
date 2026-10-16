#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 5] Executing End-to-End System Health Checks ==="

PASSED=0
TOTAL=9

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

# 3. Tier 3 Edge Appliance Daemon
check_artifact "Tier 3: sentinel binary" "test -x /usr/local/bin/sentinel"

# 4. Extensibility Toolchain
check_artifact "Toolchain: sentinel-spkg CLI" "test -x /usr/local/bin/sentinel-spkg"

# 5. Dependency Manager CLI
check_artifact "Toolchain: sentinel-ctl CLI" "test -x /usr/local/bin/sentinel-ctl && /usr/local/bin/sentinel-ctl --help"

# 6. Tier 4 Continuous Retraining CLI
check_artifact "Tier 4: forge-cli runtime" "/usr/local/bin/forge-cli --help"

# 7. Tier 5 Academic Lab Testbed
check_artifact "Tier 5: sentinel_lab binary" "test -x /usr/local/bin/sentinel_lab"

# 8. Tier 6 Nexus Command Plane & CLI
check_artifact "Tier 6: sentinel-nexus & nexus-ctl" "test -x /usr/local/bin/sentinel-nexus && test -x /usr/local/bin/nexus-ctl"

# 9. Central Cache Root
check_artifact "Filesystem: /var/cache/sentinel" "test -d /var/cache/sentinel"

echo "--------------------------------------------------------"
echo "[+] Smoke Test Results: ${PASSED}/${TOTAL} Health Checks Verified."
if [ "${PASSED}" -eq "${TOTAL}" ]; then
    echo -e "\033[32m[+] All ecosystem tiers, toolchains, and daemons verified successfully!\033[0m"
    exit 0
else
    echo -e "\033[31m[-] Some artifacts failed verification. Check build logs above.\033[0m"
    exit 1
fi