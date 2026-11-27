#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 2] Synchronizing All 14 Ecosystem Repositories ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_DIR="${SENTINEL_WORKSPACE:-$(cd "${STACK_ROOT}/.." && pwd)}"

declare -A REPOS=(
    ["sentinel-fs"]="https://github.com/kamisaberi/sentinel-fs.git"
    ["xinfer-essential"]="https://github.com/kamisaberi/xinfer-essential.git"
    ["blackbox-essential"]="https://github.com/kamisaberi/blackbox-essential.git"
    ["blackbox-sentinel"]="https://github.com/kamisaberi/blackbox-sentinel.git"
    ["xinfer-forge"]="https://github.com/kamisaberi/xinfer-forge.git"
    ["ics-guard"]="https://github.com/kamisaberi/ics-guard.git"
    ["ccsds-guard"]="https://github.com/kamisaberi/ccsds-guard.git"
    ["net-guard"]="https://github.com/kamisaberi/net-guard.git"
    ["motion-guard"]="https://github.com/kamisaberi/motion-guard.git"
    ["vision-guard"]="https://github.com/kamisaberi/vision-guard.git"
    ["sentinel-matrix"]="https://github.com/kamisaberi/sentinel-matrix.git"
    ["sentinel-lab"]="https://github.com/kamisaberi/sentinel-lab.git"
    ["sentinel-nexus"]="https://github.com/kamisaberi/sentinel-nexus.git"
)

for NAME in "${!REPOS[@]}"; do
    DEST="${WORKSPACE_DIR}/${NAME}"
    if [[ -d "${DEST}" ]]; then
        echo "  ✓ Present : ${DEST}"
    else
        echo "  → Cloning : ${NAME} -> ${DEST}"
        git clone --depth 1 "${REPOS[$NAME]}" "${DEST}" || echo "  [!] Warning: Clone failed for ${NAME}"
    fi
done
echo "[+] Phase 2 complete (Workspace: ${WORKSPACE_DIR})."
