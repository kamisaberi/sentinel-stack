#!/usr/bin/env bash
set -euo pipefail

echo "=== [PHASE 3] 5-Tier Topological DAG Compilation (All 14 Repositories) ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_DIR="${SENTINEL_WORKSPACE:-$(cd "${STACK_ROOT}/.." && pwd)}"
VENV_DIR="/opt/sentinel-stack/venv"

MEM_MB="$(free -m | awk '/^Mem:/{print $2}')"
JOBS="$([[ "${MEM_MB}" -lt 4000 ]] && echo 2 || nproc)"
echo "[+] Threads: ${JOBS} | Workspace: ${WORKSPACE_DIR}"

# --- TIER 0A: sentinel-fs ---
echo -e "\n\033[36m[*] [Tier 0] sentinel-fs...\033[0m"
FS_DIR="${WORKSPACE_DIR}/sentinel-fs"
cmake -B "${FS_DIR}/build" -S "${FS_DIR}" -DCMAKE_BUILD_TYPE=Release
cmake --build "${FS_DIR}/build" -j"${JOBS}"
cmake --install "${FS_DIR}/build"
ldconfig
[[ -x "${VENV_DIR}/bin/pip" ]] && "${VENV_DIR}/bin/pip" install -e "${FS_DIR}" --no-deps --quiet
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    USER_SITE="$(sudo -u "${SUDO_USER}" python3 -c 'import site; print(site.getusersitepackages())')"
    sudo -u "${SUDO_USER}" mkdir -p "${USER_SITE}"
    echo "${FS_DIR}/python" | sudo -u "${SUDO_USER}" tee "${USER_SITE}/sentinel_fs.pth" >/dev/null
    sudo -u "${SUDO_USER}" sfs init
fi
SENTINEL_ROOT="/var/lib/sentinel" sfs init

# --- TIER 0B: xinfer-essential ---
echo -e "\n\033[36m[*] [Tier 0] xinfer-essential...\033[0m"
XI_DIR="${WORKSPACE_DIR}/xinfer-essential"
cmake -B "${XI_DIR}/build" -S "${XI_DIR}" -DCMAKE_BUILD_TYPE=Release -DXINFER_BUILD_EXAMPLES=OFF
cmake --build "${XI_DIR}/build" -j"${JOBS}"
cmake --install "${XI_DIR}/build"
ldconfig

# --- TIER 0C: blackbox-essential ---
echo -e "\n\033[36m[*] [Tier 0] blackbox-essential...\033[0m"
BB_DIR="${WORKSPACE_DIR}/blackbox-essential"
(cd "${BB_DIR}" && [[ -f "scripts/build_ebpf.sh" ]] && bash scripts/build_ebpf.sh || true)
cmake -B "${BB_DIR}/build" -S "${BB_DIR}" -DCMAKE_BUILD_TYPE=Release -DBLACKBOX_BUILD_TESTS=OFF
cmake --build "${BB_DIR}/build" -j"${JOBS}"
cmake --install "${BB_DIR}/build"
ldconfig
cp -u "${BB_DIR}/src/mitigation/"*.o /etc/sentinel/ 2>/dev/null || true

# --- TIER 1: blackbox-sentinel & xinfer-forge ---
echo -e "\n\033[36m[*] [Tier 1] blackbox-sentinel & xinfer-forge...\033[0m"
BS_DIR="${WORKSPACE_DIR}/blackbox-sentinel"
if [[ ! -f "${BS_DIR}/third_party/wasm3/build/source/libm3.a" && -d "${BS_DIR}/third_party/wasm3" ]]; then
    cmake -B "${BS_DIR}/third_party/wasm3/build" -S "${BS_DIR}/third_party/wasm3" -DBUILD_WASI=none -DCMAKE_BUILD_TYPE=Release
    cmake --build "${BS_DIR}/third_party/wasm3/build" -j"${JOBS}" --target m3
fi
[[ -d "${WORKSPACE_DIR}/sentinel-nexus/proto" ]] && { mkdir -p "${BS_DIR}/proto"; cp -u "${WORKSPACE_DIR}/sentinel-nexus/proto/"*.proto "${BS_DIR}/proto/"; }
cmake -B "${BS_DIR}/build" -S "${BS_DIR}" -DCMAKE_BUILD_TYPE=Release
cmake --build "${BS_DIR}/build" -j"${JOBS}" --target sentinel sentinel_ctl sentinel_artifact sentinel_plugin_pack
cmake --install "${BS_DIR}/build"
ln -sf /usr/local/bin/sentinel-artifact /usr/local/bin/sentinel-spkg

FORGE_DIR="${WORKSPACE_DIR}/xinfer-forge"
cat << FORGEC > /usr/local/bin/forge-cli
#!/usr/bin/env bash
source "${VENV_DIR}/bin/activate"
export PYTHONPATH="${FORGE_DIR}:${FORGE_DIR}/src:${FORGE_DIR}/forge:\${PYTHONPATH:-}"
exec "${VENV_DIR}/bin/python3" -m forge.cli "\$@"
FORGEC
chmod +x /usr/local/bin/forge-cli

# --- TIER 2: All 5 Production Domain Cartridges + Pack Staging ---
declare -A CTARGETS=(
    ["ics-guard"]="ics_guard ics_guard_static ics-guard-ctl aryo-ics mock_plc ics_guard_dissector_plugin"
    ["ccsds-guard"]="ccsds_guard ccsds_guard_static ccsds-guard-ctl aryo-aerospace ccsds_guard_dissector_plugin"
    ["net-guard"]="net_guard net_guard_static net-guard-ctl aryo-net net_guard_dissector_plugin"
    ["motion-guard"]="motion_guard motion_guard_static motion-guard-ctl aryo-motion motion_guard_dissector_plugin"
    ["vision-guard"]="vision_guard vision_guard_static vision-guard-ctl aryo-vision vision_guard_dissector_plugin"
)

for CART in ics-guard ccsds-guard net-guard motion-guard vision-guard; do
    C_DIR="${WORKSPACE_DIR}/${CART}"
    [[ ! -d "${C_DIR}" ]] && { echo "[!] Missing ${CART}, skipping."; continue; }
    echo -e "\n\033[36m[*] [Tier 2] Cartridge: ${CART}...\033[0m"
    cmake -B "${C_DIR}/build" -S "${C_DIR}" -DCMAKE_BUILD_TYPE=Release
    # shellcheck disable=SC2086
    cmake --build "${C_DIR}/build" -j"${JOBS}" --target ${CTARGETS[$CART]}
    cmake --install "${C_DIR}/build"
    ldconfig
    PACK_DST="/opt/sentinel/packs/${CART}"
    mkdir -p "${PACK_DST}"
    for sub in web apparatus_plugins scenarios harnesses; do
        [[ -d "${C_DIR}/${sub}" ]] && cp -ru "${C_DIR}/${sub}" "${PACK_DST}/"
    done
done

# --- TIER 3 & 4: sentinel-lab, sentinel-nexus & aryo ---
echo -e "\n\033[36m[*] [Tier 3 & 4] sentinel-lab, sentinel-nexus & aryo...\033[0m"
LAB_DIR="${WORKSPACE_DIR}/sentinel-lab"
if [[ -d "${LAB_DIR}" ]]; then
    cmake -B "${LAB_DIR}/build" -S "${LAB_DIR}" -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENVINO=ON -DBUILD_TESTS=OFF
    cmake --build "${LAB_DIR}/build" -j"${JOBS}"
    cmake --install "${LAB_DIR}/build" || cp "${LAB_DIR}/build/sentinel_lab" /usr/local/bin/sentinel_lab
    cp -ru "${LAB_DIR}/harnesses/"* /opt/sentinel-stack/harnesses/ 2>/dev/null || true
    cp -ru "${LAB_DIR}/configs/"*.json /etc/sentinel/configs/ 2>/dev/null || true
fi

NEXUS_DIR="${WORKSPACE_DIR}/sentinel-nexus"
cmake -B "${NEXUS_DIR}/build" -S "${NEXUS_DIR}" -DCMAKE_BUILD_TYPE=Release
cmake --build "${NEXUS_DIR}/build" -j"${JOBS}" --target sentinel-nexus nexus-ctl
cmake --install "${NEXUS_DIR}/build"

cmake -B "${STACK_ROOT}/build" -S "${STACK_ROOT}" -DCMAKE_BUILD_TYPE=Release
cmake --build "${STACK_ROOT}/build" -j"${JOBS}" --target aryo
cmake --install "${STACK_ROOT}/build"

echo "[+] Phase 3 complete."
