### Part 5: Tier-by-Tier Build Mechanics (`compilation-dag-tiers/*`)

This section contains 8 technical implementation guides detailing the exact compilation commands, linker flags, dynamic library caches, and memory-throttled compilation steps across all six tiers in the Aryorithm ecosystem.

---

### File: `sentinel-stack/docs/compilation-dag-tiers/building-tier-1-xinfer.md`

```markdown
# Tier 1 Build Mechanics: `xinfer-essential` (`libxinfer.so`)

`xinfer-essential` is the foundational inference runtime in the topological DAG. It must be compiled and installed system-wide first so downstream tiers can locate its C++20 headers and link against `libxinfer.so`.

---

## 1. Source Directory & Build Location

* **Source Path:** `/opt/sentinel-stack/src/xinfer`
* **Build Directory:** `/opt/sentinel-stack/src/xinfer/build`
* **Installed Artifacts:**
  * Headers: `/usr/local/include/xinfer/*.hpp`
  * Shared Library: `/usr/local/lib/libxinfer.so -> libxinfer.so.1.0.0`
  * CMake Config: `/usr/local/lib/cmake/xinfer/xinferConfig.cmake`

---

## 2. Compilation Commands (`scripts/03_build_all_tiers.sh`)

```bash
cd /opt/sentinel-stack/src/xinfer
mkdir -p build && cd build

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=clang++-16 \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DXINFER_BUILD_TESTS=OFF \
    -DXINFER_ENABLE_OPENVINO=ON \
    -DXINFER_ENABLE_ZERO_COPY=ON ..

ninja -j"${PARALLEL_JOBS}"
ninja install

# Refresh dynamic linker cache immediately
ldconfig
```

---

## 3. Verification Assertion

Confirm that `libxinfer.so` is registered in `/etc/ld.so.cache`:

```bash
ldconfig -p | grep libxinfer
# Output: libxinfer.so.1 (libc6,x86-64) => /usr/local/lib/libxinfer.so.1
```
```

---

### File: `sentinel-stack/docs/compilation-dag-tiers/building-tier-2-blackbox.md`

```markdown
# Tier 2 Build Mechanics: `blackbox-essential` (`libblackbox.so`)

`blackbox-essential` requires compiling two distinct targets:
1. The in-kernel eBPF packet mitigation filter (`xdp_filter.o`) using Clang targeting the BPF virtual machine.
2. The user-space active mitigation shared library (`libblackbox.so`), which links against `libxinfer.so`.

---

## 1. Step 1: Compiling In-Kernel eBPF Bytecode

Before running CMake, the installer executes `bpf/build_bpf.sh`:

```bash
cd /opt/sentinel-stack/src/blackbox/bpf

ARCH=$(uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/')

clang-16 -O2 -g \
    -target bpf \
    -D__TARGET_ARCH_${ARCH} \
    -I/usr/include \
    -I/usr/include/$(uname -m)-linux-gnu \
    -c xdp_filter.c -o xdp_filter.o

# Install BPF bytecode object to system directory
mkdir -p /usr/local/lib/bpf
cp xdp_filter.o /usr/local/lib/bpf/xdp_filter.o
```

---

## 2. Step 2: Compiling `libblackbox.so`

```bash
cd /opt/sentinel-stack/src/blackbox
mkdir -p build && cd build

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=clang++-16 \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DBLACKBOX_BUILD_TESTS=OFF \
    -DBLACKBOX_ENABLE_TPM=ON ..

ninja -j"${PARALLEL_JOBS}"
ninja install
ldconfig
```

---

## 3. Verification Assertion

```bash
# Verify shared library and eBPF bytecode
ldconfig -p | grep libblackbox
test -f /usr/local/lib/bpf/xdp_filter.o && echo "[+] xdp_filter.o verified"
```
```

---

### File: `sentinel-stack/docs/compilation-dag-tiers/building-tier-3-sentinel.md`

```markdown
# Tier 3 Build Mechanics: `blackbox-sentinel` (`sentinel` daemon)

`blackbox-sentinel` is the commercial edge XDR appliance daemon. It links directly against **Tier 1 (`-lxinfer`)** and **Tier 2 (`-lblackbox`)**, compiling 26 native C++20 subsystems and 30 dynamic industrial protocol dissector plugins.

---

## 1. Linker Dependencies

The CMake build system resolves installed targets via standard package configurations:
* `find_package(xinfer REQUIRED CONFIG)`
* `find_package(blackbox REQUIRED CONFIG)`

---

## 2. Compilation Commands

```bash
cd /opt/sentinel-stack/src/sentinel
mkdir -p build && cd build

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=clang++-16 \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DSENTINEL_BUILD_TESTS=OFF \
    -DSENTINEL_BUILD_PLUGINS=ON ..

ninja -j"${PARALLEL_JOBS}"
ninja install
ldconfig
```

### Deployed Artifacts:
* `/usr/local/bin/sentinel`: Core daemon executable.
* `/usr/local/lib/sentinel-plugins/*.so`: 30 protocol dissector shared libraries.

---

## 3. Verification Assertion

```bash
/usr/local/bin/sentinel --version
# Expected Output: sentinel version 2.4.0 (Aryorithm Technologies B.V.)
```
```

---

### File: `sentinel-stack/docs/compilation-dag-tiers/building-tier-4-forge.md`

```markdown
# Tier 4 Build Mechanics: `xinfer-forge` (`forge-cli`)

`xinfer-forge` is the continual active learning daemon. To comply with PEP 668, it is installed inside `/opt/sentinel-stack/venv` and symlinked to `/usr/local/bin/forge-cli`.

---

## 1. Installation Commands

```bash
cd /opt/sentinel-stack/src/forge

# Install package into the isolated virtual environment
/opt/sentinel-stack/venv/bin/pip install .

# Create global binary symlink
ln -sf /opt/sentinel-stack/venv/bin/forge-cli /usr/local/bin/forge-cli
chmod +x /usr/local/bin/forge-cli
```

---

## 2. Verification Assertion

Verify that `forge-cli` executes properly using the virtual environment's Python interpreter:

```bash
forge-cli --version
# Expected Output: xinfer-forge version 2.4.0 (Aryorithm Continual AI Engine)
```
```

---

### File: `sentinel-stack/docs/compilation-dag-tiers/building-tier-5-lab.md`

```markdown
# Tier 5 Build Mechanics: `sentinel-lab` (`sentinel_lab`)

`sentinel-lab` provides the SLAB protocol benchmarking engine and raw socket testbed. It links against `libxinfer.so` and `libblackbox.so`.

---

## 1. Compilation Commands

```bash
cd /opt/sentinel-stack/src/lab
mkdir -p build && cd build

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=clang++-16 \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DENABLE_OPENVINO=ON \
    -DBUILD_BENCHMARKS=ON ..

ninja -j"${PARALLEL_JOBS}"
ninja install
```

### Deployed Artifacts:
* `/usr/local/bin/sentinel_lab`: Benchmark evaluation engine.
* `/usr/local/bin/slab_generator`: Dataset serializer tool.

---

## 2. Verification Assertion

```bash
test -x /usr/local/bin/sentinel_lab && echo "[+] sentinel_lab binary verified"
```
```

---

### File: `sentinel-stack/docs/compilation-dag-tiers/building-tier-6-nexus.md`

```markdown
# Tier 6 Build Mechanics: `sentinel-nexus` (`sentinel-nexus` & `nexus-ctl`)

`sentinel-nexus` is the master fleet command plane. It links against gRPC, Protocol Buffers, OpenSSL, and internal data structures, compiling the command daemon, operations CLI, and embedded web UI.

---

## 1. Compilation Commands

```bash
cd /opt/sentinel-stack/src/nexus
mkdir -p build && cd build

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=clang++-16 \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DNEXUS_BUILD_CLI=ON \
    -DNEXUS_BUILD_TESTS=OFF ..

ninja -j"${PARALLEL_JOBS}"
ninja install
ldconfig
```

### Deployed Artifacts:
* `/usr/local/bin/sentinel-nexus`: Fleet command daemon.
* `/usr/local/bin/nexus-ctl`: Administrative CLI tool.

---

## 2. Verification Assertion

```bash
nexus-ctl --version
# Expected Output: nexus-ctl version 2.4.0 (Aryorithm Fleet Command CLI)
```
```

---

### File: `sentinel-stack/docs/compilation-dag-tiers/dynamic-linker-cache-ldconfig.md`

```markdown
# Dynamic Linker Cache Refreshes (`ldconfig`)

In Linux, newly installed shared libraries in `/usr/local/lib` are invisible to downstream compiler link steps until the system dynamic linker cache (`/etc/ld.so.cache`) is refreshed.

---

## 1. The Inter-Tier Linker Refresh Invariant

`03_build_all_tiers.sh` enforces an explicit `ldconfig` run immediately after installing each tier:

```bash
# Topological step:
build_tier_1
ninja install
ldconfig # Updates /etc/ld.so.cache with libxinfer.so

build_tier_2
ninja install
ldconfig # Updates /etc/ld.so.cache with libblackbox.so

build_tier_3 # Successfully resolves -lxinfer and -lblackbox!
```

---

## 2. Custom Library Search Path Configuration

Phase 1 registers `/usr/local/lib` and the plugin directory in `/etc/ld.so.conf.d/sentinel.conf`:

```text
/usr/local/lib
/usr/local/lib/sentinel-plugins
/usr/local/lib/matrix-deps
```

This guarantees that both the host operating system and container runtimes resolve Aryorithm shared libraries without requiring manual `LD_LIBRARY_PATH` exports.
```

---

### File: `sentinel-stack/docs/compilation-dag-tiers/parallel-job-scaling-ram.md`

```markdown
# Parallel Compilation Scaling & RAM Sizing (`make -j`)

Compiling deep C++20 template metaprogramming libraries (such as gRPC stubs, OpenVINO tensor headers, and eBPF wrappers) consumes significant memory during compiler optimization passes. Executing `make -j$(nproc)` on memory-constrained systems causes internal compiler Out-of-Memory (OOM) fatal crashes (`signal 9: Killed`).

---

## 1. Dynamic Parallelism Sizing Algorithm

Phase 0 (`00_check_system.sh`) evaluates total system RAM and dynamically scales compiler parallelism:

$$\text{Jobs} = \min\left(\text{CPU Cores},\, \max\left(1,\, \left\lfloor \frac{\text{RAM}_{\text{Total GB}}}{2.5} \right\rfloor\right)\right)$$

```text
 ┌─────────────────────────────────────────────────────────────┐
 │ RAM-Aware Parallelism Allocation Rule                       │
 ├─────────────────────────────────────────────────────────────┤
 │ • RAM < 8 GB   ──► Cap to -j2 (Prevents compiler OOM crash) │
 │ • RAM < 16 GB  ──► Cap to -j4                               │
 │ • RAM >= 32 GB ──► Full Parallelism: -j$(nproc)             │
 └─────────────────────────────────────────────────────────────┘
```

---

## 2. Implementation in `00_check_system.sh`

```bash
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
CPU_CORES=$(nproc)

if [ "${TOTAL_RAM_GB}" -lt 8 ]; then
    export PARALLEL_JOBS=2
elif [ "${TOTAL_RAM_GB}" -lt 16 ]; then
    export PARALLEL_JOBS=$((CPU_CORES > 4 ? 4 : CPU_CORES))
else
    export PARALLEL_JOBS="${CPU_CORES}"
fi

echo "export PARALLEL_JOBS=${PARALLEL_JOBS}" > /opt/sentinel-stack/.build_env
```
```

---

### Complete in Part 5
- `sentinel-stack/docs/compilation-dag-tiers/building-tier-1-xinfer.md`
- `sentinel-stack/docs/compilation-dag-tiers/building-tier-2-blackbox.md`
- `sentinel-stack/docs/compilation-dag-tiers/building-tier-3-sentinel.md`
- `sentinel-stack/docs/compilation-dag-tiers/building-tier-4-forge.md`
- `sentinel-stack/docs/compilation-dag-tiers/building-tier-5-lab.md`
- `sentinel-stack/docs/compilation-dag-tiers/building-tier-6-nexus.md`
- `sentinel-stack/docs/compilation-dag-tiers/dynamic-linker-cache-ldconfig.md`
- `sentinel-stack/docs/compilation-dag-tiers/parallel-job-scaling-ram.md`

All 8 Compilation DAG Tier documentation files are now generated.

---

### Files to be Generated in Part 6

The next phase covers **Systemd Daemonization & Linux Service Hardening** (`systemd-daemonization/` - 6 files):

1. `systemd-daemonization/systemd-architecture.md` (Lifecycle management, auto-restart circuits, and dependencies)
2. `systemd-daemonization/sentinel-nexus-service.md` (Configuring `sentinel-nexus.service`: WorkingDir, ports, ulimits)
3. `systemd-daemonization/blackbox-sentinel-service.md` (Configuring `sentinel.service`: Real-time priorities)
4. `systemd-daemonization/linux-capabilities-management.md` (Granting `CAP_NET_ADMIN`, `CAP_BPF` without full root)
5. `systemd-daemonization/real-time-process-scheduling.md` (Real-time round-robin scheduling: `SCHED_RR`, priority 98, nice -20)
6. `systemd-daemonization/daemon-logging-and-journalctl.md` (Centralized logging, journalctl filtering, and log rotation)

Confirm when you are ready to proceed with Part 6.