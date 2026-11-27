#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 4] Deploying Systemd Daemons & SSFS Initialization ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${SENTINEL_WORKSPACE:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"

mkdir -p /etc/sentinel/configs /opt/sentinel-nexus/web /opt/sentinel-nexus/configs
if command -v sfs >/dev/null 2>&1; then
    SENTINEL_ROOT="/var/lib/sentinel" sfs init
    if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
        sudo -u "${SUDO_USER}" sfs init || true
    fi
fi

[[ ! -f "/opt/sentinel-nexus/web/index.html" && -d "${WORKSPACE_DIR}/sentinel-nexus/web" ]] && \
    cp -ru "${WORKSPACE_DIR}/sentinel-nexus/web/"* /opt/sentinel-nexus/web/ 2>/dev/null || true

cat << 'UNIT' > /etc/systemd/system/sentinel-nexus.service
[Unit]
Description=Sentinel Nexus - Sovereign Fleet C2 Plane (Tier 4)
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/sentinel-nexus
ExecStart=/usr/local/bin/sentinel-nexus /opt/sentinel-nexus/configs/nexus.yaml
Restart=always
RestartSec=5s
LimitNOFILE=65536
TasksMax=4096

[Install]
WantedBy=multi-user.target
UNIT

cat << 'UNIT' > /etc/systemd/system/blackbox-sentinel.service
[Unit]
Description=Blackbox Sentinel - Universal Multi-Bus Defense Node (Tier 1)
After=network.target sentinel-nexus.service
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/sentinel
ExecStart=/usr/local/bin/sentinel --routes /etc/sentinel/model_routes.yaml
Restart=always
RestartSec=5s
LimitNOFILE=65536
LimitMEMLOCK=infinity
TasksMax=4096
CPUSchedulingPolicy=rr
CPUSchedulingPriority=50
AmbientCapabilities=CAP_NET_ADMIN CAP_SYS_ADMIN CAP_BPF CAP_SYS_RESOURCE CAP_NET_RAW

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable sentinel-nexus.service
systemctl restart sentinel-nexus.service || true
echo "[+] Phase 4 complete."
