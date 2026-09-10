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

