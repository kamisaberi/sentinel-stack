---

### File: `sentinel-stack/docs/verification-and-smoke-tests/tier-4-forge-cli-check.md`

```markdown
# Tier 4 Assertion Check: `xinfer-forge` (`forge-cli`)

Verifies that the isolated Python virtual environment (`/opt/sentinel-stack/venv`) executes properly and that `forge-cli` runs without PEP 668 restrictions.

---

## 1. Automated Assertion Commands

```bash
# 1. Verify global wrapper symlink
test -x /usr/local/bin/forge-cli || exit 1

# 2. Verify CLI version execution
/usr/local/bin/forge-cli --version | grep -q "version 2.4.0" || exit 1

# 3. Test PyTorch tensor allocation inside the virtualenv
/opt/sentinel-stack/venv/bin/python3 -c "
import torch
x = torch.randn(1, 32)
assert x.shape == (1, 32)
" || exit 1

# 4. Test ONNX exporter import
/opt/sentinel-stack/venv/bin/python3 -c "import onnx; import onnxruntime" || exit 1
```

---

## 2. Diagnostic Remediation

If the virtual environment is corrupted:
* Re-provision `/opt/sentinel-stack/venv` via `scripts/01_install_dependencies.sh`.
```

---

### File: `sentinel-stack/docs/verification-and-smoke-tests/tier-5-sentinel-lab-check.md`

```markdown
# Tier 5 Assertion Check: `sentinel-lab` (`sentinel_lab`)

Verifies that the SLAB benchmark research testbed compiles, executes, and locates its dataset conversion tools.

---

## 1. Automated Assertion Commands

```bash
# 1. Verify testbed binary execution
test -x /usr/local/bin/sentinel_lab || exit 1

# 2. Check help flag response
/usr/local/bin/sentinel_lab --help | grep -q "SLAB" || exit 1

# 3. Verify dataset serializer script
test -f /opt/sentinel-stack/src/lab/tools/csv_to_slab.py || exit 1
```

---

## 2. Diagnostic Remediation

If `sentinel_lab` fails to build:
* Check CMake configuration options in `/opt/sentinel-stack/src/lab/build/CMakeCache.txt`.
```

---

### File: `sentinel-stack/docs/verification-and-smoke-tests/tier-6-nexus-ctl-check.md`

```markdown
# Tier 6 Assertion Check: `sentinel-nexus` & `nexus-ctl`

Verifies that the central command daemon and operations CLI execute, bind network listener ports, and authenticate commands.

---

## 1. Automated Assertion Commands

```bash
# 1. Verify CLI executable
test -x /usr/local/bin/nexus-ctl || exit 1

# 2. Verify CLI version execution
/usr/local/bin/nexus-ctl --version | grep -q "nexus-ctl version 2.4.0" || exit 1

# 3. Verify service daemon binary
test -x /usr/local/bin/sentinel-nexus || exit 1

# 4. Verify systemd service status
systemctl is-active --quiet sentinel-nexus.service || exit 1

# 5. Verify network listener ports (50051 gRPC, 9443 REST, 9444 SSE)
ss -tulpn | grep -q ":50051" || exit 1
ss -tulpn | grep -q ":9443" || exit 1
ss -tulpn | grep -q ":9444" || exit 1
```

---

## 2. Diagnostic Remediation

If port 50051 or 9443 is not listening:
* Check systemd service logs: `journalctl -u sentinel-nexus -n 50 --no-pager`.
```

---

### File: `sentinel-stack/docs/verification-and-smoke-tests/automated-ci-cd-integration.md`

```markdown
# Automated Continuous Integration (CI/CD Pipeline)

`sentinel-stack` can be executed within GitHub Actions or GitLab CI runners to validate builds and dependency graphs on every commit.

---

## 1. GitHub Actions Workflow (`.github/workflows/stack_ci.yml`)

```yaml
name: Sentinel-Stack CI Quality Gate

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-verify:
    runs-on: ubuntu-24.04
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Execute Sentinel-Stack 1-Click Installer
        run: |
          sudo ./install.sh

      - name: Run Automated Post-Installation Smoke Tests
        run: |
          sudo make verify

      - name: Audit Dynamic Library Bundling
        run: |
          test -d /opt/sentinel-matrix/shared/lib && ls -lh /opt/sentinel-matrix/shared/lib
```
```

