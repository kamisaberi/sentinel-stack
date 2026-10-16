To execute **Move 3 (Master Meta-Installer Upgrade in `sentinel-stack`)** safely without breaking your existing 6-phase topological compilation DAG or deployment scripts:

Per our standing rule to inspect existing files before making any modifications, please share:

1. **`/home/kami/sentinel-stack/install.sh`**
2. Any existing systemd service templates or config files in `sentinel-stack/` (e.g., in `sentinel-stack/configs/` or `sentinel-stack/scripts/`).

---

### What We Will Be Adding to `sentinel-stack`

Once you share `install.sh`, we will update it to incorporate all the new capabilities we built:

1. **Filesystem & Cache Provisioning:**
   * Pre-provisioning the Content-Addressable Cache directory: `/var/cache/sentinel/{packages,models,pcaps,datasets}` with proper ownership.
   * Pre-provisioning the runtime directories: `/etc/sentinel/{plugins.d,wasm.d,rules.d,models,pcaps,datasets}`.
   * Mounting and persisting `/sys/fs/bpf` with `rw,nosuid,nodev,noexec,relatime,mode=700`.
2. **Dependency Resolution for New Subsystems:**
   * Adding `libxdp-dev`, `libluajit-5.1-dev`, `luajit`, `bpftool`, and `clang` packages to the Phase 1 dependency installer.
3. **Topological Compilation DAG Update (Phase 3):**
   * Compiling the new build targets: `sentinel-spkg`, `sentinel-ctl`, `test_extensibility`, and `test_af_xdp_live`.
   * Building the embedded Wasm3 static library (`libm3.a`) and `sentinel-hub` packages during installation.
4. **Hardened Systemd Service Units (Phase 4):**
   * Updating `blackbox-sentinel.service` and `sentinel-nexus.service` with Linux capabilities:
     `AmbientCapabilities=CAP_NET_ADMIN CAP_BPF CAP_SYS_RESOURCE CAP_NET_RAW`
   * Real-time scheduling (`LimitMEMLOCK=infinity`, `CPUSchedulingPolicy=rr`, `CPUSchedulingPriority=50`).
5. **Phase 5 Smoke Test Updates:**
   * Adding health checks for `sentinel-ctl status`, eBPF map attachment, and the 1440px Web C2 on port 9443.

Paste your current `/home/kami/sentinel-stack/install.sh` to begin.