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

