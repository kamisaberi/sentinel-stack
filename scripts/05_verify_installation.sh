#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 5] Executing End-to-End System Health Checks ==="

PASSED=0
TOTAL=6

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

# 2. Tier 2 Shared Library & eBPF
check_artifact "Tier 2: libblackbox.so" "test -f /usr/local/lib/libblackbox.so && ldconfig -p | grep libblackbox"

# 3. Tier 3 Edge Appliance Daemon
check_artifact "Tier 3: sentinel binary" "test -x /usr/local/bin/sentinel"

# 4. Tier 4 Continuous Retraining CLI
check_artifact "Tier 4: forge-cli runtime" "/usr/local/bin/forge-cli --help"

# 5. Tier 5 Academic Lab Testbed
check_artifact "Tier 5: sentinel_lab binary" "test -x /usr/local/bin/sentinel_lab"

# 6. Tier 6 Nexus Command Plane & CLI
check_artifact "Tier 6: sentinel-nexus & nexus-ctl" "test -x /usr/local/bin/sentinel-nexus && test -x /usr/local/bin/nexus-ctl"

echo "--------------------------------------------------------"
echo "[+] Smoke Test Results: ${PASSED}/${TOTAL} Tiers Verified Healthy."
if [ "${PASSED}" -eq "${TOTAL}" ]; then
    echo -e "\033[32m[+] All 6 tiers compiled, linked, and verified successfully!\033[0m"
    exit 0
else
    echo -e "\033[31m[-] Some artifacts failed verification. Check build logs above.\033[0m"
    exit 1
fi