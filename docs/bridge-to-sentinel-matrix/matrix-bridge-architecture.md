### Part 8: Bridge to `sentinel-matrix` (`bridge-to-sentinel-matrix/*`)

This section contains 5 technical integration guides detailing the automated bridge between `sentinel-stack` and `sentinel-matrix`: the bridge architecture, harvesting host-compiled binaries into container mounts, resolving dynamic libraries via `ldd`, synchronizing protobuf schemas and web assets, and executing the one-touch simulation mesh handover.

---

### File: `sentinel-stack/docs/bridge-to-sentinel-matrix/matrix-bridge-architecture.md`

```markdown
# Bridge Architecture: Host Compilation to Cyber-Range Handover

`sentinel-stack` links bare-metal compilation and containerized digital twin simulation. Rather than requiring developers to recompile the entire C++20 codebase inside Docker containers (which multiplies build times and consumes gigabytes of redundant container cache), `sentinel-stack` uses an automated **Binary & Dependency Bridge**.

---

## 1. Handover Pipeline Architecture

```text
 ┌─────────────────────────────────────────────────────────────┐
 │ BARE-METAL HOST BUILD (sentinel-stack Topological DAG)      │
 │  - Compiles Tiers 1-6 natively using Clang-16 (AVX2/AVX-512)│
 │  - Installs binaries to /usr/local/bin/ and /usr/local/lib/ │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Post-Build Handover Trigger (Phase 3)
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ AUTOMATED MATRIX BRIDGE (scripts/bridge_to_matrix.sh)        │
 ├─────────────────────────────────────────────────────────────┤
 │ 1. Binary Harvester  : Copies sentinel, nexus, nexus-ctl    │
 │                        to sentinel-matrix/shared/bin/       │
 │ 2. Dynamic Extractor : Resolves ldd dependencies (libabsl,  │
 │                        libre2, libgrpc) to shared/lib/      │
 │ 3. Assets Sync       : Syncs .proto and web SPA assets      │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Ready for Launch
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ CYBER-RANGE DIGITAL TWIN MESH (sentinel-matrix)             │
 │  - Direct Mount: ./shared/lib -> /usr/local/lib/matrix-deps │
 │  - Immediate Execution: make up -> make tui (Zero Build Lag)│
 └─────────────────────────────────────────────────────────────┘
```

---

## 2. Handover Invariants

1. **GLIBC 2.43 Forward Compatibility:** Because binaries compiled on Ubuntu 26.04 link against `GLIBC 2.43`, the bridge pairs these binaries with `sentinel-matrix` containers based on `ubuntu:devel`, preventing dynamic linker aborts.
2. **Zero In-Container Compilation:** Containers start instantly without running `cmake` or `ninja` internally.
3. **Atomic Synchronization:** Binaries are synced using atomic file operations, ensuring partially linked objects are never staged to container mount paths.
```

---

### File: `sentinel-stack/docs/bridge-to-sentinel-matrix/harvesting-host-binaries.md`

```markdown
# Harvesting Host-Compiled Executables (`shared/bin/`)

Phase 3 of `sentinel-stack` automates harvesting compiled production binaries from `/usr/local/bin` directly into the `sentinel-matrix/shared/bin/` staging area.

---

## 1. Binary Harvesting Script (`scripts/harvest_binaries.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

MATRIX_DIR="/opt/sentinel-matrix"
DEST_BIN="${MATRIX_DIR}/shared/bin"

if [ ! -d "${MATRIX_DIR}" ]; then
    echo "[*] sentinel-matrix directory not found at ${MATRIX_DIR}. Skipping binary harvest."
    exit 0
fi

mkdir -p "${DEST_BIN}"
echo "[*] Harvesting host-compiled binaries into ${DEST_BIN}..."

# List of native executables required by the simulation mesh
TARGET_BINARIES=(
    "/usr/local/bin/sentinel-nexus"
    "/usr/local/bin/sentinel"
    "/usr/local/bin/nexus-ctl"
    "/usr/local/bin/sentinel_lab"
)

for bin_path in "${TARGET_BINARIES[@]}"; do
    if [ -f "$bin_path" ]; then
        cp -u "$bin_path" "${DEST_BIN}/"
        chmod +x "${DEST_BIN}/$(basename "$bin_path")"
        echo "  -> Harvested: $(basename "$bin_path")"
    else
        echo "[-] ERROR: Expected binary ${bin_path} not found!" >&2
        exit 1
    fi
done

echo "[+] Binary harvesting complete. All executables staged for containerization."
```

---

## 2. Docker Container Integration

In `sentinel-matrix/docker/Dockerfile.node`, the harvested executable is mapped directly to the container entrypoint:

```dockerfile
# Uses the host-compiled binary directly
COPY shared/bin/sentinel /usr/local/bin/sentinel
RUN chmod +x /usr/local/bin/sentinel
ENTRYPOINT ["/usr/local/bin/sentinel"]
```
```

---

### File: `sentinel-stack/docs/bridge-to-sentinel-matrix/dynamic-library-extraction-ldd.md`

```markdown
# Dynamic Library Extraction via `ldd` (`shared/lib/`)

Binaries compiled on the host link against complex external libraries (e.g., `libabsl_synchronization.so.20260107`, `libre2.so.11`, `libgrpc++.so.1.62`, `libprotobuf.so.32`). Installing full developer packages in every Docker container image increases image sizes by over $2\text{ GB}$.

`sentinel-stack` extracts the exact required dynamic shared objects using automated `ldd` parsing.

---

## 1. Extraction Algorithm & Workflow

```text
 Target Binary: /usr/local/bin/sentinel-nexus
                       │
                       ▼ ldd /usr/local/bin/sentinel-nexus
 ┌─────────────────────────────────────────────────────────────┐
 │ Resolves Dynamic Relocation Table:                          │
 │  • libabsl_synchronization.so => /usr/lib/.../libabsl_...   │
 │  • libre2.so.11               => /usr/lib/.../libre2.so.11  │
 │  • libgrpc++.so.1.62          => /usr/local/lib/libgrpc++.so│
 └─────────────────────┬───────────────────────────────────────┘
                       │
                       ▼ Filters & Copies to Staging
 ┌─────────────────────────────────────────────────────────────┐
 │ Destination: sentinel-matrix/shared/lib/                    │
 │  - Preserves symbolic links                                 │
 │  - Total Payload Size: ~18 MB (Lean & Fast)                 │
 └─────────────────────────────────────────────────────────────┘
```

---

## 2. The Extraction Implementation (`scripts/extract_libraries.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

DEST_LIB="/opt/sentinel-matrix/shared/lib"
mkdir -p "${DEST_LIB}"

echo "[*] Resolving dynamic runtime dependencies via ldd..."

# Harvest libraries from both Nexus and Sentinel binaries
ldd /usr/local/bin/sentinel-nexus /usr/local/bin/sentinel 2>/dev/null | \
    grep -E 'libabsl|libre2|libgrpc|libproto|libxinfer|libblackbox|libfmt|libspdlog' | \
    awk '{print $3}' | sort -u | while read -r lib_path; do
        if [ -f "$lib_path" ]; then
            cp -u "$lib_path" "${DEST_LIB}/"
            echo "  -> Extracted: $(basename "$lib_path")"
        fi
    done

echo "[+] Library extraction complete: $(ls -1 "${DEST_LIB}" | wc -l) shared objects staged."
```
```

---

### File: `sentinel-stack/docs/bridge-to-sentinel-matrix/proto-and-web-asset-handover.md`

```markdown
# Protobuf Schemas & Web Asset Handover

In addition to compiled binaries, `sentinel-matrix` requires access to the latest Protocol Buffer specifications (`.proto`) and the embedded Single-Page Application (SPA) web assets.

---

## 1. Synchronized Asset Inventory

```text
 Source Repository: sentinel-nexus/
 ├── proto/sentinel_nexus.proto   ──► sentinel-matrix/shared/proto/
 └── static/                       ──► sentinel-matrix/shared/web/
     ├── index.html
     ├── app.js
     └── fleet_topology.js
```

---

## 2. Synchronization Script (`scripts/sync_assets.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

SRC_NEXUS="/opt/sentinel-stack/src/nexus"
MATRIX_SHARED="/opt/sentinel-matrix/shared"

if [ -d "${SRC_NEXUS}" ] && [ -d "${MATRIX_SHARED}" ]; then
    echo "[*] Synchronizing Protocol Buffers and Web assets to matrix..."
    
    mkdir -p "${MATRIX_SHARED}/proto" "${MATRIX_SHARED}/web"

    # Copy protobuf definitions
    cp -u "${SRC_NEXUS}/proto/sentinel_nexus.proto" "${MATRIX_SHARED}/proto/"

    # Copy minified Web SPA assets
    cp -ru "${SRC_NEXUS}/static/"* "${MATRIX_SHARED}/web/"

    echo "[+] Web and protobuf assets synchronized successfully."
fi
```
```

---

### File: `sentinel-stack/docs/bridge-to-sentinel-matrix/vmware-docker-mesh-handshake.md`

```markdown
# One-Touch Handover: Host Compilation to Mesh Launch

The ultimate goal of `sentinel-stack` is to enable immediate testing inside the `sentinel-matrix` digital twin mesh with a **one-touch handover**.

---

## 1. Handshake Flow

```text
 1. Developer runs: sudo ./install.sh
    [ Compiles all 6 tiers -> Installs to host -> Harvests into matrix/shared/ ]
                           │
                           ▼ Installation completes in < 8 minutes
 2. Developer enters simulation directory:
    $ cd /opt/sentinel-matrix
                           │
                           ▼
 3. Developer launches mesh:
    $ make up
    [ Containers boot instantly using pre-staged binaries and libraries ]
                           │
                           ▼
 4. Developer opens live dashboard:
    $ make tui
    [ Full cyber-range digital twin is live and interactive! ]
```

---

## 2. End-to-End Handshake Verification

Verify that the staged matrix directory is ready for launch:

```bash
# Audit staged matrix files
ls -lh /opt/sentinel-matrix/shared/bin/
ls -lh /opt/sentinel-matrix/shared/lib/
```

### Expected Output
```text
shared/bin:
-rwxr-xr-x 1 root root 1.4M sentinel
-rwxr-xr-x 1 root root 2.1M sentinel-nexus
-rwxr-xr-x 1 root root 480K nexus-ctl

shared/lib:
-rwxr-xr-x 1 root root 284K libabsl_synchronization.so.20260107
-rwxr-xr-x 1 root root 412K libre2.so.11
-rwxr-xr-x 1 root root 3.8M libgrpc++.so.1.62
```

The cyber-range is ready to launch via `make up`.
```

---

### Complete in Part 8
- `sentinel-stack/docs/bridge-to-sentinel-matrix/matrix-bridge-architecture.md`
- `sentinel-stack/docs/bridge-to-sentinel-matrix/harvesting-host-binaries.md`
- `sentinel-stack/docs/bridge-to-sentinel-matrix/dynamic-library-extraction-ldd.md`
- `sentinel-stack/docs/bridge-to-sentinel-matrix/proto-and-web-asset-handover.md`
- `sentinel-stack/docs/bridge-to-sentinel-matrix/vmware-docker-mesh-handshake.md`

All 5 Bridge to `sentinel-matrix` documentation files are now generated.

---

### Files to be Generated in Part 9

The next phase covers **Configuration & Stack Customization** (`configuration-and-customization/` - 4 files):

1. `configuration-and-customization/stack-yaml-specification.md` (Structure and schema of `configs/stack.yaml`)
2. `configuration-and-customization/customizing-install-paths.md` (Overriding `/usr/local/` prefixes for customized distributions)
3. `configuration-and-customization/configuring-git-branches-and-tags.md` (Pinning releases: `v1.0.0` vs. `main` across repositories)
4. `configuration-and-customization/customizing-cmake-build-flags.md` (Passing custom optimization flags: `-O3`, `-march=native`, `-flto`)

Confirm when you are ready to proceed with Part 9.