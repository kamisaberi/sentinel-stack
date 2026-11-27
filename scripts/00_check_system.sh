#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 0] System Environment, Kernel eBPF & OpenSSL PQC Check ==="
[[ -f /etc/os-release ]] && { . /etc/os-release; echo "[+] OS: ${NAME} ${VERSION_ID}"; }

ARCH="$(uname -m)"
echo "[+] Arch: ${ARCH} | Kernel: $(uname -r) | Cores: $(nproc) | RAM: $(free -m | awk '/^Mem:/{print $2}') MB"
if [[ "${ARCH}" != "x86_64" && "${ARCH}" != "aarch64" ]]; then
    echo "[-] Error: Unsupported architecture: ${ARCH}"; exit 1
fi

[[ -f /sys/kernel/btf/vmlinux ]] && echo "[+] Kernel BTF: OK" || echo "[!] Warning: /sys/kernel/btf/vmlinux missing"
command -v openssl >/dev/null 2>&1 && echo "[+] OpenSSL: $(openssl version)"

if [[ ! -d /sys/fs/bpf ]]; then
    mkdir -p /sys/fs/bpf
    mount -t bpf bpf /sys/fs/bpf 2>/dev/null || true
fi

mkdir -p /etc/sentinel/{plugins.d,wasm.d,rules.d,models,configs,env} \
         /opt/sentinel/packs /opt/sentinel-stack/harnesses /usr/local/lib/blackbox
chmod 755 /etc/sentinel /opt/sentinel /opt/sentinel/packs
echo "[+] Phase 0 passed."
