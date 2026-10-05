---

### File: `sentinel-stack/docs/troubleshooting/missing-kernel-headers.md`

```markdown
# Debugging Missing Linux Kernel Headers during eBPF Compilation

Phase 3 compiles the in-kernel eBPF filter (`blackbox/bpf/xdp_filter.c`). If the host system's kernel development headers do not match the running kernel release (`uname -r`), compilation halts.

---

## 1. Symptom & Error Trace

```text
In file included from xdp_filter.c:1:
/usr/include/linux/bpf.h:11:10: fatal error: 'linux/types.h' file not found
#include <linux/types.h>
          ^~~~~~~~~~~~~~~
1 error generated.
[-] eBPF compilation failed!
```

---

## 2. Diagnosing Kernel Header Version Mismatch

Verify whether the installed headers match your active kernel:

```bash
# Check running kernel release
uname -r

# Inspect installed header directories
ls -d /usr/src/linux-headers-*
```

### The "Updated But Un-Rebooted" Trap:
If `uname -r` outputs `6.8.0-31-generic`, but `/usr/src/` only contains `linux-headers-6.8.0-35-generic`, an automated `apt upgrade` updated the kernel packages on disk, but the host has not yet rebooted into the new kernel.

---

## 3. Remediation

### Scenario A: Reboot Host (Recommended)
Reboot the machine into the updated kernel release:

```bash
sudo reboot
```

### Scenario B: Install Exact Matching Headers
If rebooting is restricted, install the header package matching the active running kernel:

```bash
sudo apt-get update
sudo apt-get install -y linux-headers-$(uname -r)
```

Verify that `/usr/src/linux-headers-$(uname -r)` exists, then restart installation: `sudo ./install.sh`.
```

---

### File: `sentinel-stack/docs/troubleshooting/grpc-protobuf-linking-errors.md`

```markdown
# Resolving gRPC & Protocol Buffers Linking Errors

When building Tier 6 (`sentinel-nexus`), the linker resolves symbols across `libgrpc++`, `libprotobuf`, and Abseil. If system libraries are mismatched or multiple Protobuf versions coexist, linking fails.

---

## 1. Symptom & Linker Trace

```text
/usr/bin/ld: CMakeFiles/sentinel-nexus.dir/src/nexus/main.cpp.o: in function `sentinel::nexus::FleetServiceImpl::SubmitHeartbeat(...)':
main.cpp:(.text+0x1420): undefined reference to `google::protobuf::Message::InitializationErrorString[abi:cxx11]() const'
/usr/bin/ld: main.cpp:(.text+0x1580): undefined reference to `grpc::ServerBuilder::AddListeningPort(...)'
clang-16: error: linker command failed with exit code 1
```

---

## 2. Root Cause Analysis

1. **Protobuf ABI Divergence:** A locally compiled Protobuf version in `/usr/local/lib` conflicts with the Ubuntu system package in `/usr/lib/x86_64-linux-gnu`.
2. **Ubuntu 24.04/26.04 `t64` Header Mismatches:** Installing `libprotobuf-dev` without updating `libgrpc++-dev` creates an incompatible mix of 64-bit `time_t` shared objects.

---

## 3. Remediation

### Step 1: Re-install Unified System Packaging
Ensure consistent system versions of the gRPC toolchain:

```bash
sudo apt-get update
sudo apt-get install --reinstall -y \
    protobuf-compiler-grpc \
    libprotobuf-dev \
    libgrpc++-dev
```

### Step 2: Clear Stale CMake Cache
Purge the build directory to force CMake to rediscover system package configurations:

```bash
rm -rf /opt/sentinel-stack/src/nexus/build
```

### Step 3: Verify Protobuf Version Alignment
Ensure the `protoc` compiler matches the linked library headers:

```bash
protoc --version
pkg-config --modversion protobuf
```

Both outputs must report identical major version baselines. Re-run `./install.sh`.
```

---

### File: `sentinel-stack/docs/troubleshooting/python-externally-managed-errors.md`

```markdown
# Resolving Python PEP 668 `externally-managed-environment` Errors

On modern Linux operating systems (Ubuntu 24.04 LTS, Ubuntu 26.04 Devel, Debian 12), attempting to install Python packages globally via `pip` fails with a system protection block.

---

## 1. Symptom

```text
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
```

---

## 2. Why `--break-system-packages` Must Be Avoided

Passing `--break-system-packages` forces `pip` to overwrite files managed by APT, which can break system Python packages used by `cloud-init`, `netplan`, or `gdb`.

---

## 3. The `sentinel-stack` Architectural Solution

`sentinel-stack` never modifies global Python site-packages. All Python runtime dependencies (PyTorch, ONNX, NumPy) are isolated within **`/opt/sentinel-stack/venv`**.

If you encounter this error while testing `xinfer-forge` manually, ensure you execute commands using the virtual environment's pip binary:

```bash
# Correct invocation:
sudo /opt/sentinel-stack/venv/bin/pip install <package_name>

# Running forge-cli directly:
/usr/local/bin/forge-cli --help
```
```

---

### File: `sentinel-stack/docs/troubleshooting/systemd-service-failed-starts.md`

```markdown
# Diagnosing Systemd Service Launch Failures (`status=203/EXEC`, `status=1`)

If `sentinel-nexus.service` or `sentinel.service` fails to start during Phase 4, inspect the systemd exit code to pinpoint the root cause.

---

## 1. `status=203/EXEC` (Executable Not Found or Permissions Denied)

### Symptom:
```text
● sentinel.service - Aryorithm Blackbox-Sentinel Cyber-Physical Edge XDR Appliance
     Loaded: loaded (/etc/systemd/system/sentinel.service; enabled)
     Active: failed (Result: exit-code)
    Process: 18402 ExecStart=/usr/local/bin/sentinel (code=exited, status=203/EXEC)
```

### Cause:
The binary `/usr/local/bin/sentinel` does not exist, was not granted executable permissions, or is missing the execute bit (`chmod +x`).

### Remediation:
```bash
test -f /usr/local/bin/sentinel && sudo chmod +x /usr/local/bin/sentinel
```

---

## 2. `status=1/FAILURE` (Configuration File Missing or Invalid)

### Symptom:
```text
Process: 18402 ExecStart=/usr/local/bin/sentinel (code=exited, status=1/FAILURE)
```

### Remediation:
Inspect detailed failure messages using `journalctl`:

```bash
sudo journalctl -u sentinel -xe --no-pager
```

Check for missing runtime configuration files:
* If the error reports `Failed to open /etc/sentinel/sentinel.yaml`:
  ```bash
  sudo mkdir -p /etc/sentinel
  sudo cp /opt/sentinel-stack/src/sentinel/configs/sentinel.yaml /etc/sentinel/sentinel.yaml
  ```
* Validate YAML syntax:
  ```bash
  sentinel --validate-config /etc/sentinel/sentinel.yaml
  ```

---

## 3. `status=217/USER` or Permission Denied on `/dev/tpmrm0`

Ensure the service user has permission to access the TPM 2.0 Resource Manager:

```bash
sudo usermod -aG tss root
sudo chmod 660 /dev/tpmrm0
```
```

---

### File: `sentinel-stack/docs/troubleshooting/dynamic-linker-library-not-found.md`

```markdown
# Resolving Dynamic Linker Errors: `cannot open shared object file`

When executing installed binaries (`sentinel`, `sentinel-nexus`, or `nexus-ctl`), the dynamic linker may fail to locate newly compiled shared libraries in `/usr/local/lib`.

---

## 1. Symptom

```text
sentinel: error while loading shared libraries: libxinfer.so.1: cannot open shared object file: No such file or directory
nexus-ctl: error while loading shared libraries: libblackbox.so.1: cannot open shared object file: No such file or directory
```

---

## 2. Root Cause Analysis

By default, some minimal Linux distributions do not include `/usr/local/lib` in the trusted dynamic linker search path evaluated by `/etc/ld.so.cache`.

---

## 3. Remediation

### Step 1: Register Custom Linker Configuration
Ensure `/etc/ld.so.conf.d/sentinel.conf` contains the standard installation directories:

```bash
cat << 'EOF' | sudo tee /etc/ld.so.conf.d/sentinel.conf
/usr/local/lib
/usr/local/lib/sentinel-plugins
/usr/local/lib/matrix-deps
EOF
```

### Step 2: Rebuild Dynamic Linker Cache
Run `ldconfig` with root privileges:

```bash
sudo ldconfig
```

### Step 3: Verify Symbol Resolution
Confirm that the dynamic linker resolves all required libraries:

```bash
ldd /usr/local/bin/sentinel
# All dependencies should report absolute paths (e.g. => /usr/local/lib/libxinfer.so.1)
```
```

---

### File: `sentinel-stack/docs/troubleshooting/faq.md`

```markdown
# Technical Frequently Asked Questions (FAQ)

---

### Q1: How long does the complete 1-click installation take?
On a standard modern 8-core server with an NVMe SSD and 16 GB of RAM, the complete end-to-end installation (compiling all 6 tiers, eBPF bytecode, and provisioning the Python virtual environment) completes in **7 to 9 minutes**.

---

### Q2: Can `sentinel-stack` run on ARM64 architectures (e.g., Raspberry Pi 5, Rockchip RK3588)?
**Yes.** The installer automatically detects `aarch64` architectures via `uname -m`, sets the appropriate eBPF target architecture (`-D__TARGET_ARCH_arm64`), configures ARM Neon SIMD instructions, and resolves ARM64-compatible PyTorch wheels.

---

### Q3: Does `sentinel-stack` overwrite existing configuration files during updates?
**No.** When re-running `sudo ./install.sh` or `sudo make update`, existing configuration manifests in `/etc/sentinel/sentinel.yaml` and `/etc/sentinel-nexus/nexus.yaml` are preserved. New configuration templates are written with a `.new` extension to prevent accidental overwrites.

---

### Q4: How does `sentinel-stack` interface with `sentinel-matrix`?
After compiling the native binaries and shared objects on the host, Phase 3 automatically executes `scripts/harvest_binaries.sh` and `scripts/extract_libraries.sh`. This copies executables and dynamic libraries (`libabsl`, `libre2`, `libgrpc`) directly into `sentinel-matrix/shared/lib/` and `shared/bin/`, allowing immediate launch of the digital twin range (`make up`).

---

### Q5: How do I perform a completely air-gapped offline installation?
Download the pre-seeded bundle (`sentinel-stack-airgapped.tar.gz`) on an internet-connected system, transfer it to the target machine via physical media, extract it to `/opt/sentinel-stack/`, and execute:

```bash
sudo ./install.sh --offline
```
```

---

### File: `sentinel-stack/docs/troubleshooting/support.md`

```markdown
# Enterprise Support SLAs, Issue Escalation & Bug Reporting

---

## 1. Automated Diagnostic Bundle Generation

When reporting an issue with build failures, compiler crashes, or systemd daemonization, generate an automated diagnostic bundle:

```bash
sudo /opt/sentinel-stack/scripts/collect_diagnostics.sh --output /tmp/stack_diagnostics.tar.gz
```

This bundle packages:
* Host operating system details, kernel release, and hardware architecture (`uname -a`, `lscpu`).
* Complete installation log from `/var/log/sentinel_install.log`.
* Active dynamic linker cache configuration (`/etc/ld.so.conf.d/`).
* Output from `05_verify_installation.sh` quality gate smoke tests.
* Systemd service unit journals for `sentinel` and `sentinel-nexus`.

---

## 2. Commercial Support & Turn-Key Deployment SLAs

Aryorithm Technologies B.V. provides commercial engineering support for enterprise and defense deployments:

| Support Tier | Target Response Time | Availability | Scope |
| :--- | :--- | :--- | :--- |
| **Standard Commercial**| 8 Business Hours | Mon–Fri 08:00–18:00 CET | Build troubleshooting, dependency resolution. |
| **Mission-Critical Defense**| **1 Hour (24/7/365)** | Round-the-Clock | Dedicated systems architect, kernel-level triage, custom BSP porting, on-site deployment audits. |

For technical inquiries and enterprise SLA contracts:
* **Customer Portal:** `https://app.aryorithm.com/support`
* **Email:** `support@aryorithm.com`

---

## 3. Coordinated Security Vulnerability Disclosure

If you identify a security bypass, privilege escalation flaw, or memory corruption vulnerability in `sentinel-stack`:
* Send an encrypted PGP message to **`security@aryorithm.com`**.
* We acknowledge disclosures within **48 hours** and provide CVE assignment, risk remediation, and backported security patches according to coordinated disclosure guidelines.
```

