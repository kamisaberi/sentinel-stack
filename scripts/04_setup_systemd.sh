#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 4] Deploying Linux Systemd Daemons ==="

# 1. Sentinel Nexus Service Unit
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

# 2. Blackbox Sentinel Edge Daemon Unit (With eBPF & AF_XDP Real-Time Scheduling)
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