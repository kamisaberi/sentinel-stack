#!/usr/bin/env bash
# Single Duty: Reset AppArmor profiles and restart Docker daemon
set -euo pipefail

echo "[*] Resetting AppArmor profiles and restarting Docker/containerd..."
sudo aa-remove-unknown 2>/dev/null || true
sudo systemctl restart containerd docker
echo "[+] Containerd and Docker shims reset."
