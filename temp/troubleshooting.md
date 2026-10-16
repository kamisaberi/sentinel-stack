# Sentinel-Stack: Master Architecture, Operations & Troubleshooting Manual

---

## 1. Architecture of the 6-Phase Topological DAG

`sentinel-stack` is a deterministic 1-click meta-installer and compiler pipeline for **Ubuntu 24.04 LTS / 26.04 Devel** across bare-metal, VMware, and Docker environments. It executes a strict linear Directed Acyclic Graph (DAG):

```text
========================================================================================================================
                                     SENTINEL-STACK 6-PHASE INSTALLATION DAG
========================================================================================================================

  [ PHASE 0: 00_check_system.sh ]
  • Probes CPU architecture (x86_64 / aarch64), RAM (min 4GB), and Hypervisor (VMware/KVM).
  • Validates Kernel BTF (/sys/kernel/btf/vmlinux) for eBPF CO-RE.
  • Mounts BPF filesystem (/sys/fs/bpf) & provisions /var/cache/sentinel/ and /etc/sentinel/.
                 │
                 ▼
  [ PHASE 1: 01_install_dependencies.sh ]
  • Installs core compilers: Clang, LLVM, LLD, CMake, GCC, bpftool, libbpf-dev, libxdp-dev.
  • Installs runtime libraries: libluajit-5.1-dev, libsqlite3-dev, libssl-dev, gRPC, Protobuf.
  • Creates isolated virtual environment at /opt/sentinel-stack/venv to bypass PEP 668.
                 │
                 ▼
  [ PHASE 2: 02_clone_repositories.sh ]
  • Synchronizes 6 core repositories: xinfer-essential, blackbox-essential, blackbox-sentinel,
    sentinel-lab, sentinel-nexus, and sentinel-hub.
  • Priority Resolution: Local workspace (/home/kami/) rsync first, GitHub clone fallback.
                 │
                 ▼
  [ PHASE 3: 03_build_all_tiers.sh ]
  • Topological Compilation DAG:
    Tier 1 (libxinfer.so) ──► Tier 2 (libblackbox.so & eBPF CO-RE) ──► Tier 3 (sentinel, sentinel-spkg, sentinel-ctl)
    ──► Tier 4 (forge-cli) ──► Tier 5 (sentinel_lab) ──► Tier 6 (sentinel-nexus & nexus-ctl)
    ──► Sentinel-Hub (Seals Core 8 .spkg packages and populates /var/cache/sentinel/).
                 │
                 ▼
  [ PHASE 4: 04_setup_systemd.sh ]
  • Deploys hardened Linux daemons: `sentinel-nexus.service` and `blackbox-sentinel.service`.
  • Grants real-time capabilities: `CAP_NET_ADMIN`, `CAP_BPF`, `CAP_SYS_RESOURCE`, `CAP_NET_RAW`.
  • Enforces `LimitMEMLOCK=infinity` and real-time scheduling (`SCHED_RR` priority 50).
                 │
                 ▼
  [ PHASE 5: 05_verify_installation.sh ]
  • Executes 9/9 automated end-to-end smoke tests (libraries, daemons, CLI tools, cache, ports).
========================================================================================================================
```

---

## 2. Complete Troubleshooting Matrix

| Category | Observed Error / Symptom | Root Cause | Permanent Resolution |
| :--- | :--- | :--- | :--- |
| **Permissions** | `sudo ./scripts/05_verify_installation.sh: permission denied` | Execute bit (`+x`) missing on script files. | `chmod +x scripts/*.sh install.sh` |
| **Permissions** | `rsync: mkstemp failed: Permission denied (13)` in Phase 2 | `sentinel-stack/src/` owned by `root:root` from previous `sudo` run. | `sudo chown -R $USER:$USER /home/kami/sentinel-stack` |
| **Python / Forge** | `ModuleNotFoundError: No module named 'forge'` | `02_clone_repositories.sh` checked wrong path for `xinfer-forge`. | Update script to check `/home/kami/xinfer-forge` first. |
| **Python / Forge** | `ModuleNotFoundError: No module named 'forge.models'` | `rsync` had `--exclude 'models'`, stripping the `forge/models/` package. | Change to `--exclude '/checkpoints'` in `02_clone_repositories.sh`. |
| **Compilers** | `sentinel_ctl.cpp: error: ‘geteuid’ was not declared in this scope` | Missing `<unistd.h>` header for POSIX `geteuid()` check. | Add `#include <unistd.h>` to `tools/sentinel_ctl.cpp`. |
| **Compilers** | `error: ‘AF_INET’ was not declared in this scope` in `sentinel_ctl` | Missing socket headers for `cmd_slab_stream`. | Add `<sys/socket.h>`, `<netinet/in.h>`, `<arpa/inet.h>`. |
| **Linker** | `undefined reference to 'EVP_MD_CTX_new'` in `sentinel_ctl` | `CMakeLists.txt` missing `OpenSSL::Crypto` linkage for target. | Add `OpenSSL::Crypto` to `target_link_libraries(sentinel_ctl)`. |
| **C++ / AF_XDP** | `invalid use of incomplete type ‘struct xsk_umem_info’` | Forward declaration in global namespace instead of `blackbox::ingest`. | Wrap internal state in `UmemContext` inside `blackbox::ingest`. |
| **C++ / AF_XDP** | `error: ‘XDP_ZERO_COPY’ was not declared; did you mean ‘XDP_ZEROCOPY’?` | Kernel header `<linux/if_xdp.h>` uses `XDP_ZEROCOPY` (no underscore). | Change to `XDP_ZEROCOPY` in `af_xdp_engine.cpp`. |
| **Linker** | `undefined reference to blackbox::ingest::AfXdpEngine::~AfXdpEngine()` | `libblackbox.so` built with hidden visibility; missing `BLACKBOX_API`. | Annotate `class BLACKBOX_API AfXdpEngine` in `af_xdp_engine.hpp`. |
| **Runtime / eBPF**| `libbpf: elf: failed to open src/mitigation/xdp_drop.o: -ENOENT` | Hardcoded relative path failed when run from `build/` directory. | Add multi-path resolver (`../`, `/etc/sentinel/`, absolute). |
| **Networking** | `failed to bind host port 0.0.0.0:9443/tcp: address already in use` | Phase 4 started host systemd service, colliding with Docker matrix. | Stop host service: `sudo systemctl stop sentinel-nexus.service`. |
| **Docker / OS** | `Cannot restart container ...: permission denied` | Ubuntu AppArmor locking orphaned `containerd-shim` PID namespaces. | `sudo aa-remove-unknown && sudo pkill -9 -f containerd-shim`. |
| **Python / System**| `error: externally-managed-environment` under Ubuntu 24.04/26.04 | PEP 668 restricts global `pip install` on modern Ubuntu. | Use `/opt/sentinel-stack/venv` virtual environment. |

---

## 3. Deep-Dive Failure Analysis & Field Fixes

---

### Failure 1: Script Permission Denied (`sudo ./scripts/...: permission denied`)

* **Symptom:**
  ```text
  kami@kami-VMware-Virtual-Platform:~/sentinel-stack$ sudo ./scripts/05_verify_installation.sh
  sudo: ./scripts/05_verify_installation.sh: command not found / permission denied
  ```
* **Root Cause:** In Linux, even when executing under `sudo` (root), the kernel checks the **execute bit (`+x`)** in file permissions. If the script was cloned via Git or created without `chmod +x`, execution fails.
* **Resolution:**
  ```bash
  cd /home/kami/sentinel-stack
  chmod +x install.sh scripts/*.sh
  ```

---

### Failure 2: `rsync: mkstemp failed: Permission denied (13)`

* **Symptom:**
  ```text
  rsync: [generator] recv_generator: mkdir "/home/kami/sentinel-stack/src/..." failed: Permission denied (13)
  rsync: [receiver] mkstemp "...": Permission denied (13)
  ```
* **Root Cause:** When `install.sh` runs under `sudo`, any directory it creates (such as `sentinel-stack/src/`) is assigned root ownership (`root:root`). Subsequent runs as regular user `kami` cannot create or modify files inside `src/`.
* **Resolution:**
  ```bash
  sudo chown -R $USER:$USER /home/kami/sentinel-stack
  ```

---

### Failure 3: `ModuleNotFoundError: No module named 'forge'`

* **Symptom:**
  ```text
  /opt/sentinel-stack/venv/bin/python3: Error while finding module specification for 'forge.cli' (ModuleNotFoundError: No module named 'forge')
  ```
* **Root Cause:** In `scripts/02_clone_repositories.sh`, the sync logic was hardcoded to check `${WORKSPACE_DIR}/blackbox-sentinel/xinfer-forge`. In your local workspace, the repository is located at **`/home/kami/xinfer-forge`**, so Phase 2 skipped copying it, leaving `sentinel-stack/src/xinfer-forge` empty.
* **Resolution:** Ensure `scripts/02_clone_repositories.sh` checks `/home/kami/xinfer-forge` first:
  ```bash
  if [ -d "${WORKSPACE_DIR}/xinfer-forge" ]; then
      mkdir -p "${TARGET_DIR}/xinfer-forge"
      rsync -a --delete --exclude '/checkpoints' "${WORKSPACE_DIR}/xinfer-forge/" "${TARGET_DIR}/xinfer-forge/"
  fi
  ```

---

### Failure 4: `ModuleNotFoundError: No module named 'forge.models'`

* **Symptom:**
  ```text
  File ".../forge/main.py", line 8, in <module>
      from forge.models.autoencoder import NetworkAnomalyAutoencoder
  ModuleNotFoundError: No module named 'forge.models'
  ```
* **Root Cause:** In `rsync`, passing `--exclude 'models'` matches **any directory named `models` anywhere in the tree**. Because the core Python neural network code lives in `forge/models/` (`autoencoder.py`), `rsync` inadvertently stripped the Python package.
* **Resolution:** Change `--exclude 'models'` to `--exclude '/checkpoints'` so only heavy training checkpoint directories are skipped.

---

### Failure 5: Compiler Missing System Headers (`geteuid`, `AF_INET`, `sockaddr_in`)

* **Symptom:**
  ```text
  tools/sentinel_ctl.cpp: error: ‘geteuid’ was not declared in this scope
  tools/sentinel_ctl.cpp: error: ‘AF_INET’ was not declared in this scope
  ```
* **Root Cause:** GCC 14/15 on Ubuntu 24.04/26.04 enforces strict C++20 header isolation. Standard POSIX system calls are no longer pulled in transitively.
* **Resolution:** Explicitly include the POSIX and Linux network headers at the top of `tools/sentinel_ctl.cpp`:
  ```cpp
  #include <unistd.h>
  #include <sys/socket.h>
  #include <netinet/in.h>
  #include <arpa/inet.h>
  ```

---

### Failure 6: OpenSSL Crypto Linker Error (`undefined reference to 'EVP_MD_CTX_new'`)

* **Symptom:**
  ```text
  CMakeFiles/sentinel_ctl.dir/tools/sentinel_ctl.cpp.o: in function `sha256_buffer':
  undefined reference to `EVP_MD_CTX_new'
  undefined reference to `PEM_read_PUBKEY'
  ```
* **Root Cause:** When the `sentinel_ctl` binary was updated to verify Ed25519 signatures and calculate SHA-256 Merkle roots, `CMakeLists.txt` linked only `Threads::Threads` without linking `OpenSSL::Crypto` (`-lcrypto`).
* **Resolution:** In `blackbox-sentinel/CMakeLists.txt`, update `target_link_libraries`:
  ```cmake
  add_executable(sentinel_ctl tools/sentinel_ctl.cpp)
  target_link_libraries(sentinel_ctl PRIVATE Threads::Threads OpenSSL::Crypto)
  ```

---

### Failure 7: Incomplete Type `xsk_umem_info` / GCC 15 `std::unique_ptr`

* **Symptom:**
  ```text
  error: invalid use of incomplete type ‘struct xsk_umem_info’
  error: invalid application of ‘sizeof’ to incomplete type ‘xsk_umem_info’
  ```
* **Root Cause:** In `include/blackbox/af_xdp_engine.hpp`, `struct xsk_umem_info;` was forward-declared in the **global namespace**, but in `src/ingest/af_xdp_engine.cpp`, it was defined inside **`namespace blackbox::ingest`**. GCC 15 treated `::xsk_umem_info` as an incomplete type inside `std::unique_ptr`.
* **Resolution:** Rename the internal wrappers to `UmemContext` and `SocketContext` and ensure both forward declaration and definition are inside `namespace blackbox::ingest`.

---

### Failure 8: Hidden Symbol Visibility on `AfXdpEngine`

* **Symptom:**
  ```text
  CMakeFiles/test_af_xdp_live.dir/examples/test_af_xdp_live.cpp.o:
  undefined reference to `blackbox::ingest::AfXdpEngine::~AfXdpEngine()'
  ```
* **Root Cause:** `blackbox-essential/CMakeLists.txt` sets `-fvisibility=hidden`. Any class exported from `libblackbox.so` must be annotated with `BLACKBOX_API` (`__attribute__((visibility("default")))`).
* **Resolution:** In `include/blackbox/af_xdp_engine.hpp`, add `#include "blackbox/export.hpp"` and annotate the class:
  ```cpp
  class BLACKBOX_API AfXdpEngine { ... };
  ```

---

### Failure 9: Host Systemd Port Collisions (`0.0.0.0:9443: address already in use`)

* **Symptom:**
  ```text
  Error response from daemon: failed to bind host port 0.0.0.0:9443/tcp: address already in use
  ```
* **Root Cause:** When `install.sh` executes Phase 4, it automatically starts `sentinel-nexus.service` on the host operating system. If you subsequently attempt to run `sentinel-matrix` via Docker, Docker fails because host port `9443` is already taken.
* **Resolution:**
  ```bash
  sudo systemctl stop sentinel-nexus.service
  sudo systemctl stop blackbox-sentinel.service 2>/dev/null || true
  ```

---

### Failure 10: Docker AppArmor Permission Denied on Container Restarts

* **Symptom:**
  ```text
  Error response from daemon: Cannot restart container ...: permission denied
  ```
* **Root Cause:** Ubuntu AppArmor profiles lock `containerd-shim` PID namespaces when containers are stopped abruptly or restarted in-place, preventing `runc` from sending termination signals.
* **Resolution:**
  ```bash
  sudo aa-remove-unknown
  sudo pkill -9 -f containerd-shim || true
  sudo systemctl daemon-reload
  sudo systemctl restart containerd docker
  ```

---

## 4. Master Clean Re-Installation Procedure

If your environment ever reaches an inconsistent state, use this procedure to reset and run a clean installation:

```bash
# 1. Stop any running containers and host services
cd /home/kami/sentinel-matrix 2>/dev/null && sudo make down 2>/dev/null || true
sudo systemctl stop sentinel-nexus.service blackbox-sentinel.service 2>/dev/null || true

# 2. Reset permissions on the source workspace
sudo chown -R $USER:$USER /home/kami/sentinel-stack

# 3. Clean stale AppArmor locks
sudo aa-remove-unknown
sudo systemctl restart containerd docker

# 4. Make all installer scripts executable
cd /home/kami/sentinel-stack
chmod +x install.sh scripts/*.sh

# 5. Run the master meta-installer
sudo ./install.sh
```

### Expected Output (Verification Phase 5):
```text
=== [PHASE 5] Executing End-to-End System Health Checks ===
[*] Testing Tier 1: libxinfer.so... [PASS]
[*] Testing Tier 2: libblackbox.so... [PASS]
[*] Testing Tier 3: sentinel binary... [PASS]
[*] Testing Toolchain: sentinel-spkg CLI... [PASS]
[*] Testing Toolchain: sentinel-ctl CLI... [PASS]
[*] Testing Tier 4: forge-cli runtime... [PASS]
[*] Testing Tier 5: sentinel_lab binary... [PASS]
[*] Testing Tier 6: sentinel-nexus & nexus-ctl... [PASS]
[*] Testing Filesystem: /var/cache/sentinel... [PASS]
--------------------------------------------------------
[+] Smoke Test Results: 9/9 Health Checks Verified.
[+] All ecosystem tiers, toolchains, and daemons verified successfully!
```