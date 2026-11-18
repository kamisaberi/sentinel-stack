#!/usr/bin/env bash
# ==============================================================================
# 04_audit_ebpf_xdp.sh — Audits In-Kernel XDP Programs and BPF Drop Maps
# ==============================================================================
set -euo pipefail

CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}================================================================================${RESET}"
echo -e "${CYAN}           ARYORITHM BLACKBOX: IN-KERNEL eBPF / XDP AUDITOR                     ${RESET}"
echo -e "${CYAN}================================================================================${RESET}"

echo -e "[*] Probing active network interfaces for attached XDP programs:"
if command -v ip >/dev/null 2>&1; then
    ip link show | grep -E "xdp|eth[0-9]|ens[0-9]|veth" || echo "  No XDP flags currently exposed on host interfaces."
fi
echo ""

echo -e "[*] Auditing pinned BPF filesystem (/sys/fs/bpf):"
if [[ -d "/sys/fs/bpf" ]]; then
    sudo ls -la /sys/fs/bpf/
else
    echo -e "${YELLOW}[!] /sys/fs/bpf is not mounted on host.${RESET}"
fi
echo ""

echo -e "[*] Checking live drop counters across active edge containers:"
for c in $(docker ps --filter "name=matrix-.*(edge|uav)" --format "{{.Names}}"); do
    echo -e "  • Container: ${CYAN}${c}${RESET}"
    docker exec "${c}" bpftool map list 2>/dev/null || \
        docker logs --tail=100 "${c}" 2>&1 | grep -E "IN-KERNEL DROP|KernelDropInjector|XDP_DROP" | tail -n 5 || echo "    No drop events logged."
done

echo -e "\n${GREEN}[+] eBPF audit complete.${RESET}"
