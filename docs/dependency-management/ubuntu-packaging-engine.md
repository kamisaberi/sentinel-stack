### Part 4: Dependency Management & OS Toolchain Resolution (`dependency-management/*`)

This section contains 6 technical implementation guides detailing how `sentinel-stack` resolves Ubuntu 24.04 and 26.04 package management challenges: non-interactive APT operations, 64-bit `time_t` (`t64`) transition libraries, PEP 668 Python environment isolation, eBPF toolchain alignment, silicon accelerator driver discovery, and debconf dialog suppression.

---

### File: `sentinel-stack/docs/dependency-management/ubuntu-packaging-engine.md`

```markdown
# Ubuntu Packaging Engine & Automated Dependency Resolution

`sentinel-stack` operates a package management wrapper within `scripts/01_install_dependencies.sh` designed to resolve system libraries, compilers, and development headers across **Ubuntu 24.04 LTS (Noble Numbat)** and **Ubuntu 26.04 (Devel)**.

---

## 1. Automated Repository & Mirror Verification

Before executing package downloads, the packaging engine verifies local DNS resolution and tests connectivity against the primary Ubuntu archive:

```bash
# Verify connectivity to official Ubuntu repositories
if ! curl -s --head --request GET http://archive.ubuntu.com/ubuntu/ | grep "200 OK\|301 Moved" > /dev/null; then
    echo "[!] WARN: Primary Ubuntu archive unreachable. Falling back to regional mirrors..."
    sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirror.hetzner.com/ubuntu/packages/|g' /etc/apt/sources.list
fi
```

---

## 2. APT Lock Contention Handling

In automated continuous deployment environments or cloud-init boots, background processes (such as `unattended-upgrades` or `apt-daily.service`) often hold the APT lock (`/var/lib/dpkg/lock-frontend`).

`sentinel-stack` incorporates an automated lock wait loop:

```bash
wait_for_apt_lock() {
    local max_wait=120
    local waited=0
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
        echo "[*] Waiting for background APT locks to be released (${waited}/${max_wait}s)..."
        sleep 5
        waited=$((waited + 5))
        if [ "$waited" -ge "$max_wait" ]; then
            echo "[-] Timed out waiting for APT lock. Terminating background apt processes..."
            killall apt apt-get unattended-upgrade 2>/dev/null || true
            sleep 2
            break
        fi
    done
}
```

This prevents installation aborts on newly initialized edge virtual machines.
```

