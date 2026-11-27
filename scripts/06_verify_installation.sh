#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=========================================================================="
echo "=== [PHASE 6] Executing 30-Point Sovereign Ecosystem Verification      ==="
echo "=========================================================================="

PASSED=0; TOTAL=30
check_item() {
    printf "[*] %-50s " "$1..."
    if eval "$2" >/dev/null 2>&1; then
        echo -e "\033[32m[PASS]\033[0m"; PASSED=$((PASSED + 1))
    else
        echo -e "\033[31m[FAIL]\033[0m"
    fi
}

# Tier 0 (6)
check_item "Tier 0: libsentinelfs.so & headers"         "test -f /usr/local/lib/libsentinelfs.so && test -f /usr/local/include/sentinel/fs/PathResolver.hpp"
check_item "Tier 0: sfs diagnostic CLI"                 "test -x /usr/local/bin/sfs && /usr/local/bin/sfs status"
check_item "Tier 0: Python sentinel_fs (venv)"          "/opt/sentinel-stack/venv/bin/python3 -c 'import sentinel_fs'"
check_item "Tier 0: libxinfer.so"                       "test -f /usr/local/lib/libxinfer.so && ldconfig -p | grep libxinfer"
check_item "Tier 0: libblackbox.so"                     "test -f /usr/local/lib/libblackbox.so && ldconfig -p | grep libblackbox"
check_item "Tier 0: eBPF xdp_drop.o bytecode"           "test -f /etc/sentinel/xdp_drop.o"

# Tier 1 (5)
check_item "Tier 1: sentinel daemon (+libsentinelfs)"   "test -x /usr/local/bin/sentinel && ldd /usr/local/bin/sentinel | grep sentinelfs"
check_item "Tier 1: sentinel-ctl (+libsentinelfs)"      "test -x /usr/local/bin/sentinel-ctl && ldd /usr/local/bin/sentinel-ctl | grep sentinelfs"
check_item "Tier 1: sentinel-artifact (+libsentinelfs)" "test -x /usr/local/bin/sentinel-artifact && ldd /usr/local/bin/sentinel-artifact | grep sentinelfs"
check_item "Tier 1: forge-cli runtime"                  "test -x /usr/local/bin/forge-cli"
check_item "Tier 1: mock_plc RK4 honeytap binary"       "test -x /usr/local/bin/mock_plc"

# Tier 2: 5 Cartridges (15)
for pair in "ics:ics-guard:ics_guard" "aerospace:ccsds-guard:ccsds_guard" "net:net-guard:net_guard" "motion:motion-guard:motion_guard" "vision:vision-guard:vision_guard"; do
    IFS=':' read -r sub repo lib <<< "${pair}"
    check_item "Tier 2: aryo-${sub} (+libsentinelfs)"       "test -x /usr/local/bin/aryo-${sub} && ldd /usr/local/bin/aryo-${sub} | grep sentinelfs"
    check_item "Tier 2: ${lib}_dissector_plugin.so"         "test -f /usr/local/lib/blackbox/${lib}_dissector_plugin.so"
    check_item "Tier 2: pack://${repo} staged"              "test -d /opt/sentinel/packs/${repo}"
done

# Tier 3 & 4 (4)
check_item "Tier 3: sentinel_lab binary"                "test -x /usr/local/bin/sentinel_lab"
check_item "Tier 4: sentinel-nexus (+libsentinelfs)"    "test -x /usr/local/bin/sentinel-nexus && ldd /usr/local/bin/sentinel-nexus | grep sentinelfs"
check_item "Tier 4: aryo master CLI (+libsentinelfs)"   "test -x /usr/local/bin/aryo && ldd /usr/local/bin/aryo | grep sentinelfs"
check_item "SSFS: 50-recipe scenario scripts present"   "ls \"${STACK_ROOT}/scenarios/scripts/01_\"*.sh >/dev/null 2>&1"

echo "--------------------------------------------------------------------------"
echo "[+] Verification Summary: ${PASSED}/${TOTAL} Checks Passed."
[[ "${PASSED}" -eq "${TOTAL}" ]]
