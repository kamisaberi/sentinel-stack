#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 1] Installing Toolchains, Libraries & PEP 668 Venv ==="
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    build-essential cmake clang llvm lld bpftool libbpf-dev libxdp-dev \
    libluajit-5.1-dev luajit libelf-dev libssl-dev libsqlite3-dev \
    linux-headers-generic pkg-config git curl wget rsync jq \
    protobuf-compiler libprotobuf-dev libgrpc++-dev protobuf-compiler-grpc \
    iproute2 iptables ethtool net-tools procps \
    python3 python3-dev python3-pip python3-venv

VENV_DIR="/opt/sentinel-stack/venv"
if [[ ! -d "${VENV_DIR}" ]]; then
    mkdir -p /opt/sentinel-stack
    python3 -m venv "${VENV_DIR}"
fi

"${VENV_DIR}/bin/pip" install --upgrade pip setuptools wheel
"${VENV_DIR}/bin/pip" install numpy scipy pyyaml requests rich grpcio grpcio-tools onnx
"${VENV_DIR}/bin/pip" install torch --index-url https://download.pytorch.org/whl/cpu || true
echo "[+] Phase 1 complete."
