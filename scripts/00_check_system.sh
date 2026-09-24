#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 0] System Environment & Virtualization Validation ==="

# 1. OS Verification
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "[+] Operating System: ${NAME} ${VERSION_ID} (${UBUNTU_CODENAME:-linux})"
    if [[ "${ID}" != "ubuntu" && "${ID_LIKE:-}" != *"ubuntu"* && "${ID_LIKE:-}" != *"debian"* ]]; then
        echo "[!] Warning: Target environment optimized for Ubuntu (24.04/26.04)."
    fi
fi

# 2. Kernel & Architecture
ARCH=$(uname -m)
KERNEL=$(uname -r)
echo "[+] Architecture: ${ARCH}"
echo "[+] Linux Kernel: ${KERNEL}"

if [[ "${ARCH}" != "x86_64" && "${ARCH}" != "aarch64" ]]; then
    echo "[-] Error: Unsupported CPU architecture: ${ARCH}. Must be x86_64 or aarch64."
    exit 1
fi

# 3. Memory & Core Assessment
TOTAL_MEM_MB=$(free -m | awk '/^Mem:/{print $2}')
CORES=$(nproc)
echo "[+] Available CPU Cores: ${CORES}"
echo "[+] Total RAM: ${TOTAL_MEM_MB} MB"

if [ "${TOTAL_MEM_MB}" -lt 3800 ]; then
    echo "[!] Warning: Total RAM is under 4GB. Build processes will limit parallel jobs to avoid OOM."
fi

# 4. Hypervisor Probe (VMware / Bare-metal)
if command -v systemd-detect-virt >/dev/null 2>&1; then
    VIRT=$(systemd-detect-virt || echo "none")
    echo "[+] Virtualization Platform: ${VIRT}"
fi

# 5. eBPF & BPF Filesystem Check
if [ -d /sys/fs/bpf ]; then
    echo "[+] BPF virtual filesystem mounted at /sys/fs/bpf."
else
    echo "[*] Mounting BPF virtual filesystem..."
    mkdir -p /sys/fs/bpf
    mount -t bpf bpf /sys/fs/bpf 2>/dev/null || true
fi

echo "[+] Phase 0 validation passed successfully."