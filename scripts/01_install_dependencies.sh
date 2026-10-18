#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 1] Installing Toolchains & System Dependencies ==="

export DEBIAN_FRONTEND=noninteractive

# Update package repositories
apt-get update -y

# 1. Core Compilers, Build Systems, and Kernel Tools
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    build-essential \
    cmake \
    clang \
    llvm \
    lld \
    bpftool \
    libbpf-dev \
    libxdp-dev \
    libluajit-5.1-dev \
    luajit \
    libelf-dev \
    libssl-dev \
    libsqlite3-dev \
    linux-headers-generic \
    pkg-config \
    git \
    curl \
    wget \
    rsync \
    jq

# 2. gRPC and Protocol Buffers Development Packages
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    protobuf-compiler \
    libprotobuf-dev \
    libgrpc++-dev \
    protobuf-compiler-grpc

# 3. Networking, eBPF & System Utilities
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    iproute2 \
    iptables \
    ethtool \
    net-tools \
    procps

# 4. Python Environment & System Packaging
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv

# 5. Create Centralized Python Virtual Environment (Avoiding PEP 668 restrictions)
VENV_DIR="/opt/sentinel-stack/venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "[*] Creating isolated virtual environment at ${VENV_DIR}..."
    mkdir -p /opt/sentinel-stack
    python3 -m venv "${VENV_DIR}"
fi

# Upgrade pip inside isolated environment
"${VENV_DIR}/bin/pip" install --upgrade pip setuptools wheel

# Install required Python packages for Forge, Research Harnesses, Protobuf, and TUI
"${VENV_DIR}/bin/pip" install --no-cache-dir \
    numpy \
    scipy \
    pyyaml \
    requests \
    rich \
    grpcio \
    grpcio-tools \
    onnx

echo "[+] Phase 1 dependencies installed successfully."