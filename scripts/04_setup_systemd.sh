#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 4] Deploying Linux Systemd Daemons & Filesystem Links ==="

# 1. Ensure Filesystem Invariants and Permissions
mkdir -p /var/cache/sentinel/packages /var/cache/sentinel/configs /etc/sentinel/configs /opt/sentinel-nexus/web
chmod -R 777 /var/cache/sentinel 2>/dev/null || true

# 2. Ensure Web Assets are linked to /opt/sentinel-nexus/web
if [ ! -f "/opt/sentinel-nexus/web/index.html" ]; then
    NEXUS_WEB=$(find /home/kami/sentinel-nexus -type d -name "web" 2>/dev/null | head -n 1 || true)
    if [ -n "${NEXUS_WEB}" ] && [ -d "${NEXUS_WEB}" ]; then
        cp -r "${NEXUS_WEB}"/* /opt/sentinel-nexus/web/ 2>/dev/null || true
    fi
    # If still missing, touch minimal index stub
    if [ ! -f "/opt/sentinel-nexus/web/index.html" ]; then
        touch /opt/sentinel-nexus/web/index.html
    fi
fi

# 3. Sentinel Nexus Service Unit
cat << 'EOF' > /etc/systemd/system/sentinel-nexus.service
[Unit]
Description=Sentinel Nexus - Collective Fleet Command Plane (Tier 6)
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
EOF

# 4. Blackbox Sentinel Edge Daemon Unit (With eBPF & AF_XDP Real-Time Scheduling)
cat << 'EOF' > /etc/systemd/system/blackbox-sentinel.service
[Unit]
Description=Blackbox Sentinel - Autonomous Edge XDR Engine (Tier 3)
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
EOF

# Reload and enable services
systemctl daemon-reload
systemctl enable sentinel-nexus.service
systemctl restart sentinel-nexus.service

echo "[+] Deployed and started sentinel-nexus.service."