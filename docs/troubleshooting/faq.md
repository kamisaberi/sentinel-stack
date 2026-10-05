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

