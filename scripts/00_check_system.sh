#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 0] System Environment, Kernel eBPF & OpenSSL PQC Validation ==="

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "[+] Operating System : ${NAME} ${VERSION_ID} (${UBUNTU_CODENAME:-linux})"
fi

ARCH="$(uname -m)"
echo "[+] Architecture     : ${ARCH} | Kernel: $(uname -r)"
if [[ "${ARCH}" != "x86_64" && "${ARCH}" != "aarch64" ]]; then
    echo "[-] Error: Unsupported CPU architecture: ${ARCH}."
    exit 1
fi

if [[ -f /sys/kernel/btf/vmlinux ]]; then
    echo "[+] Kernel BTF       : /sys/kernel/btf/vmlinux (eBPF CO-RE ready)"
else
    echo "[!] Warning: /sys/kernel/btf/vmlinux missing."
fi

if command -v openssl >/dev/null 2>&1; then
    echo "[+] OpenSSL Runtime  : $(openssl version)"
fi

TOTAL_MEM_MB="$(free -m | awk '/^Mem:/{print $2}')"
echo "[+] Compute Capacity : $(nproc) cores | ${TOTAL_MEM_MB} MB RAM"

if [[ ! -d /sys/fs/bpf ]]; then
    mkdir -p /sys/fs/bpf
    mount -t bpf bpf /sys/fs/bpf 2>/dev/null || true
fi

mkdir -p /etc/sentinel/{plugins.d,wasm.d,rules.d,models,configs,env} \
         /opt/sentinel/packs \
         /opt/sentinel-stack/harnesses \
         /usr/local/lib/blackbox
chmod 755 /etc/sentinel /opt/sentinel /opt/sentinel/packs

echo "[+] Phase 0 system validation passed."
