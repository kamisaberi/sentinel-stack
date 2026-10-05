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

