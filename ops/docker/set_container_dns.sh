#!/usr/bin/env bash
# Single Duty: Update DNS inside a specific running container
# Usage: ./set_container_dns.sh <container_name> [dns_ip]
set -euo pipefail

CONTAINER="${1:-}"
DNS_IP="${2:-1.1.1.1}"

if [ -z "$CONTAINER" ]; then
    echo "Usage: $0 <container_name> [dns_ip]"
    exit 1
fi

echo "[*] Setting DNS to ${DNS_IP} inside container: ${CONTAINER}..."
docker exec -u 0 "$CONTAINER" sh -c "echo 'nameserver ${DNS_IP}' > /etc/resolv.conf"
echo "[+] Container ${CONTAINER} DNS updated."
