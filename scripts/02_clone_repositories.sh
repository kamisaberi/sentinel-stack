#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 2] Synchronizing Ecosystem Repositories ==="

WORKSPACE_DIR="/home/kami"
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"
mkdir -p "${TARGET_DIR}"

declare -A REPOS=(
    ["xinfer-essential"]="https://github.com/kamisaberi/xinfer.git"
    ["blackbox-essential"]="https://github.com/kamisaberi/blackbox.git"
    ["blackbox-sentinel"]="https://github.com/kamisaberi/blackbox-sentinel.git"
    ["sentinel-lab"]="https://github.com/kamisaberi/sentinel-lab.git"
    ["sentinel-nexus"]="https://github.com/kamisaberi/sentinel-nexus.git"
)

for NAME in "${!REPOS[@]}"; do
    URL="${REPOS[$NAME]}"
    HOST_PATH="${WORKSPACE_DIR}/${NAME}"
    DEST_PATH="${TARGET_DIR}/${NAME}"

    echo "[*] Synchronizing: ${NAME}"

    # Priority 1: If repository already exists in /home/kami/, sync directly from local tree
    if [ -d "${HOST_PATH}" ]; then
        echo "    -> Found local workspace at ${HOST_PATH}. Synchronizing..."
        rsync -a --delete --exclude 'build' --exclude '.git' "${HOST_PATH}/" "${DEST_PATH}/"
    # Priority 2: Clone from GitHub
    elif [ ! -d "${DEST_PATH}" ]; then
        echo "    -> Cloning from ${URL}..."
        git clone --depth 1 "${URL}" "${DEST_PATH}" || {
            echo "[!] Warning: Git clone failed. Creating local build stub for ${NAME}..."
            mkdir -p "${DEST_PATH}"
        }
    else
        echo "    -> Up-to-date in ${DEST_PATH}."
    fi
done

# Sync xinfer-forge directory into workspace
if [ -d "${WORKSPACE_DIR}/blackbox-sentinel/xinfer-forge" ]; then
    mkdir -p "${TARGET_DIR}/xinfer-forge"
    rsync -a --delete --exclude 'models' "${WORKSPACE_DIR}/blackbox-sentinel/xinfer-forge/" "${TARGET_DIR}/xinfer-forge/"
fi

echo "[+] Phase 2 synchronization complete."