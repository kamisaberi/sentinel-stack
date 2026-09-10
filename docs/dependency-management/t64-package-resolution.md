---

### File: `sentinel-stack/docs/dependency-management/t64-package-resolution.md`

```markdown
# Managing Ubuntu 24.04/26.04 64-bit `time_t` (`t64`) Transitions

Ubuntu 24.04 (Noble Numbat) and Ubuntu 26.04 introduced the widespread **`t64` architecture transition** to address the year-2038 problem (Y2038) on 32-bit platforms, renaming hundreds of core shared library packages (e.g., `libprotobuf-dev` and `libgrpc++-dev` dependencies).

---

## 1. The `t64` Package Rename Matrix

Attempting to install hardcoded legacy package names causes broken package graph errors on Ubuntu 24.04+:

| Component | Legacy Package Name (< 24.04) | Ubuntu 24.04 / 26.04 Transition (`t64`) |
| :--- | :--- | :--- |
| **Protocol Buffers Core** | `libprotobuf32` | `libprotobuf32t64` |
| **C++ gRPC Runtime** | `libgrpc++1.51` | `libgrpc++1.51t64` or `libgrpc++-dev` meta |
| **ELF Object Access** | `libelf1` | `libelf1t64` |
| **Asynchronous Event Loop**| `libevent-2.1-7` | `libevent-2.1-7t64` |
| **String Formatting** | `libfmt9` | `libfmt9t64` |

---

## 2. Metapackage Resolution Strategy

Rather than querying architecture-specific runtime `.so` packages directly, `sentinel-stack` references standard virtual metapackages (`*-dev`) that map to the appropriate `t64` library variant:

```bash
# Correct abstraction in scripts/01_install_dependencies.sh:
apt-get install -y \
    libprotobuf-dev \
    protobuf-compiler-grpc \
    libgrpc++-dev \
    libelf-dev \
    libfmt-dev
```

This decoupling ensures that whether `sentinel-stack` executes on Ubuntu 22.04 LTS, Ubuntu 24.04 LTS, or Ubuntu 26.04 Devel, APT resolves the correct architecture symbols without manual user intervention.
```

---

### File: `sentinel-stack/docs/dependency-management/pep-668-python-virtual-env.md`

```markdown
# PEP 668 Compliance: Isolated `/opt/sentinel-stack/venv`

Modern Linux distributions enforce **Python Enhancement Proposal 668 (PEP 668)**, which prevents `pip` from installing packages into the system-wide global Python environment (`externally-managed-environment`).

`sentinel-stack` provides strict PEP 668 compliance by isolating the machine learning runtime at **`/opt/sentinel-stack/venv`**.

---

## 1. Why Avoid `--break-system-packages`?

Passing `--break-system-packages` to global `pip` overrides OS safety guards, overwriting system Python modules used by essential utilities (`software-properties-common`, `cloud-init`, and `gdb`). This can destabilize the host operating system.

---

## 2. Virtual Environment Architecture

```text
 ┌─────────────────────────────────────────────────────────────┐
 │ HOST OPERATING SYSTEM (/usr/lib/python3.12/)                │
 │  - System APT packages untouched and protected              │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Complete Isolation Boundary
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ ISOLATED RUNTIME: /opt/sentinel-stack/venv/                 │
 │  - Python 3.12 Standalone Virtual Environment               │
 │  - torch (CPU / CUDA optimized wheels)                      │
 │  - onnx (Opset 17 compiler) & onnxruntime                   │
 │  - numpy, pyyaml, requests                                  │
 └──────────────────────────────┬──────────────────────────────┘
                                │ System Symlink
                                ▼
 [ /usr/local/bin/forge-cli ] ──► Executes via /opt/sentinel-stack/venv/bin/python3
```

---

## 3. Global Executable Wrappers

To allow non-root users and systemd units to call `forge-cli` without activating the virtual environment first, `sentinel-stack` links a shebang wrapper to `/usr/local/bin/forge-cli`:

```bash
#!/usr/bin/env bash
# /usr/local/bin/forge-cli
exec /opt/sentinel-stack/venv/bin/python3 -m forge.cli "$@"
```
```

---

### File: `sentinel-stack/docs/dependency-management/ebpf-compiler-toolchains.md`

```markdown
# eBPF Compiler Toolchains & Kernel Header Alignment

Compiling in-kernel eBPF packet mitigation filters (`xdp_filter.o`) requires strict alignment between the host Clang/LLVM toolchain and the active kernel's internal header structures.

---

## 1. Toolchain Prerequisite Matrix

To compile eBPF bytecode targeting the Linux BPF virtual machine, `sentinel-stack` installs:

* **Compiler:** `clang-16` (Enforces modern BPF JIT instruction generation).
* **Assembler / Linker:** `llvm-16` and `lld-16`.
* **Object Stripper:** `llvm-strip-16` (Preserves `.BTF` debug sections while unlinking non-essential symbols).
* **Kernel Headers:** `linux-headers-$(uname -r)` matching the active running kernel release.

---

## 2. Dynamic Target Architecture Resolution

In `blackbox/bpf/build_bpf.sh`, the compiler target is resolved dynamically based on host architecture:

```bash
ARCH=$(uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/')

clang-16 -O2 -g \
    -target bpf \
    -D__TARGET_ARCH_${ARCH} \
    -I/usr/include \
    -I/usr/include/$(uname -m)-linux-gnu \
    -c xdp_filter.c -o xdp_filter.o
```

---

## 3. Kernel Header Mismatch Safeguards

If a user upgrades their Linux kernel via `apt upgrade` but has not rebooted, `uname -r` will reference the old kernel while `/usr/src/` contains headers for the new kernel.

`00_check_system.sh` detects this discrepancy before compilation begins:

```bash
if [ ! -d "/usr/src/linux-headers-$(uname -r)" ]; then
    echo "[!] WARN: Headers for running kernel $(uname -r) not found. Installing..."
    apt-get install -y linux-headers-$(uname -r) || {
        echo "[-] FATAL: Kernel headers missing. Please reboot into your updated kernel." >&2
        exit 1
    }
fi
```
```

---

### File: `sentinel-stack/docs/dependency-management/openvino-tensorrt-prerequisites.md`

```markdown
# Hardware Acceleration Discovery: Intel OpenVINO & NVIDIA CUDA

`sentinel-stack` probes the host for hardware AI accelerators (Intel NPUs, NVIDIA GPUs) during Phase 1, configuring compilation feature flags dynamically.

---

## 1. Accelerator Discovery Matrix

```text
 ┌─────────────────────────────────────────────────────────────┐
 │ Hardware Accelerator Discovery Prober                       │
 └──────────────────────────────┬──────────────────────────────┘
                                │
        ┌───────────────────────┴───────────────────────┐
        ▼ Probes for Intel Hardware                     ▼ Probes for NVIDIA Hardware
 ┌─────────────────────────────┐         ┌─────────────────────────────┐
 │ Level Zero / NPU Character  │         │ CUDA Driver & Toolkits      │
 │ /dev/accel/accel0 exists?   │         │ nvidia-smi / /usr/local/cuda│
 └──────────────┬──────────────┘         └──────────────┬──────────────┘
                │ FOUND                                 │ FOUND
                ▼                                       ▼
  -DXINFER_ENABLE_OPENVINO=ON             -DXINFER_ENABLE_TENSORRT=ON
  -DENABLE_OPENVINO=ON                    -DXINFER_ENABLE_CUDA=ON
```

---

## 2. Intel OpenVINO Toolchain Integration

When an Intel Core Ultra NPU or Arc GPU is detected:
* Installs `intel-openvino-runtime-ubuntu24` or links to `/opt/intel/openvino`.
* Binds Level Zero compute loaders (`libze_loader.so`).

---

## 3. NVIDIA CUDA Toolchain Integration

When an NVIDIA GPU (RTX A4000, Jetson Orin) is detected:
* Probes for `nvcc` and CUDA Runtime `>= 12.0`.
* Configures CMake to locate `libnvinfer.so` and `libcudart.so`.
* If CUDA drivers are absent, falls back to CPU SIMD mode without interrupting compilation.
```

---

### File: `sentinel-stack/docs/dependency-management/non-interactive-execution.md`

```markdown
# Non-Interactive Automation: Eliminating Prompts

To support automated cloud-init provisioning, PXE boot installations, and CI/CD pipelines, `sentinel-stack` suppresses all interactive debconf dialogs.

---

## 1. Environment Variable Overrides

Phase 1 exports environment variables to force non-interactive execution:

```bash
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a # Suppresses Ubuntu 24.04/26.04 needrestart dialogs
```

---

## 2. Dpkg Configuration Options

Every `apt-get` invocation uses forced configuration options:

```bash
APT_OPTS=(
    -y
    -o Dpkg::Options::="--force-confdef"
    -o Dpkg::Options::="--force-confold"
    -o Dpkg::Options::="--force-confmiss"
)

apt-get install "${APT_OPTS[@]}" <package_list>
```

### Option Rationale:
* **`--force-confdef`:** Instructs dpkg to resolve configuration file conflicts using the package maintainer's default choice without prompting.
* **`--force-confold`:** Preserves existing local configuration files if an existing file has been modified.
* **`NEEDRESTART_MODE=a`:** Suppresses the `needrestart` terminal menu that pauses script execution on modern Ubuntu releases.
```

