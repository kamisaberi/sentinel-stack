---

### File: `sentinel-stack/docs/getting-started/verifying-installed-stack.md`

```markdown
# Verifying the Installed Stack (`sudo make verify`)

After running `install.sh`, execute the automated verification test suite to ensure that all shared libraries, in-kernel BPF filters, executables, and network listeners are healthy.

---

## 1. Running the Verification Suite

Run the smoke test harness:

```bash
sudo make verify
# Or execute directly:
sudo ./scripts/05_verify_installation.sh
```

---

## 2. Expected Verification Output

```text
================================================================================
                 SENTINEL-STACK POST-BUILD QUALITY GATE
================================================================================
 [PASS] Tier 1: /usr/local/lib/libxinfer.so found in ldconfig cache.
 [PASS] Tier 2: /usr/local/lib/libblackbox.so found in ldconfig cache.
 [PASS] Tier 2: /usr/local/lib/bpf/xdp_filter.o valid BPF ELF bytecode.
 [PASS] Tier 3: /usr/local/bin/sentinel binary executable (v2.4.0 verified).
 [PASS] Tier 4: /usr/local/bin/forge-cli functional in /opt/sentinel-stack/venv.
 [PASS] Tier 5: /usr/local/bin/sentinel_lab research testbed executable.
 [PASS] Tier 6: /usr/local/bin/sentinel-nexus command daemon active.
 [PASS] Tier 6: /usr/local/bin/nexus-ctl operations CLI functional.

------------------------------ NETWORK SERVICES --------------------------------
 [PASS] gRPC Fleet Service      : Listening on 0.0.0.0:50051 (mTLS Active)
 [PASS] Web Command Center      : Listening on 0.0.0.0:9443 (HTTPS)
 [PASS] Real-Time SSE Stream    : Listening on 0.0.0.0:9444 (HTTP/1.1)

================================================================================
Status: ALL QUALITY GATES PASSED (11/11). System is operational.
================================================================================
```
```

---

### File: `sentinel-stack/docs/getting-started/architecture-at-a-glance.md`

```markdown
# Architecture at a Glance

The diagram below details the filesystem layout, compilation dependencies, and daemonization hooks provisioned by `sentinel-stack`.

---

```text
 ┌──────────────────────────────────────────────────────────────────────────────────────────┐
 │ HOST OPERATING SYSTEM: Ubuntu 24.04 / 26.04 LTS                                          │
 │                                                                                          │
 │  ┌────────────────────────────────────────────────────────────────────────────────────┐  │
 │  │ SYSTEM-WIDE COMPILATION & RUNTIME LAYOUT                                           │  │
 │  │                                                                                    │  │
 │  │  • /usr/local/include/xinfer/       : C++20 Header API (InferenceEngine, Tensor)   │  │
 │  │  • /usr/local/include/blackbox/     : C++20 Header API (XdpManager, RingBuffer)    │  │
 │  │  • /usr/local/lib/libxinfer.so      : Tier 1 Zero-Copy Inference Core               │  │
 │  │  • /usr/local/lib/libblackbox.so    : Tier 2 Active In-Kernel Mitigation Core       │  │
 │  │  • /usr/local/lib/bpf/xdp_filter.o  : In-Kernel eBPF Driver Packet Filter           │  │
 │  │  • /usr/local/bin/sentinel          : Tier 3 Commercial XDR Edge Appliance Daemon   │  │
 │  │  • /usr/local/bin/forge-cli         : Tier 4 Continual AI Active Learning CLI       │  │
 │  │  • /usr/local/bin/sentinel_lab      : Tier 5 Academic Research & Benchmark Testbed  │  │
 │  │  • /usr/local/bin/sentinel-nexus    : Tier 6 Central Fleet Command Hub Daemon       │  │
 │  │  • /usr/local/bin/nexus-ctl         : Operations & Administration CLI               │  │
 │  └───────────────────────────────────┬────────────────────────────────────────────────┘  │
 │                                      │                                                   │
 │  ┌───────────────────────────────────┴────────────────────────────────────────────────┐  │
 │  │ SYSTEMD REAL-TIME SERVICES (SCHED_RR Priority 98, Nice -20)                        │  │
 │  │  • sentinel-nexus.service   ──► Central Hub (Ports 50051, 9443, 9444)              │  │
 │  │  • sentinel.service         ──► Local Edge Defense Node (<0.84µs In-Kernel Drops)  │  │
 │  └───────────────────────────────────┬────────────────────────────────────────────────┘  │
 │                                      │                                                   │
 │  ┌───────────────────────────────────┴────────────────────────────────────────────────┐  │
 │  │ CYBER-RANGE DIGITAL TWIN BRIDGE (sentinel-matrix)                                  │  │
 │  │ Auto-harvests binaries & ldd dependencies into:                                    │  │
 │  │ sentinel-matrix/shared/{bin, lib, models, certs}/                                 │  │
 │  └────────────────────────────────────────────────────────────────────────────────────┘  │
 └──────────────────────────────────────────────────────────────────────────────────────────┘
```
```

---

### File: `sentinel-stack/docs/getting-started/post-install-next-steps.md`

```markdown
# Post-Installation Next Steps

Once `sentinel-stack` completes installation and smoke tests verify nominal status, explore the three management interfaces:

---

## 1. Access the Local Web Command Center (Port 9443)

Open your desktop browser and navigate to:

👉 **`https://localhost:9443`**

Log in using the default administrative credentials configured during installation. Explore:
* The **HTML5 Canvas Radial Fleet Topology**.
* The **Real-Time MITRE ATT&CK Threat Matrix**.
* Active in-kernel eBPF drop rules.

---

## 2. Interrogate the Fleet via `nexus-ctl`

Test the command-line administration tool:

```bash
# Query managed edge appliances
nexus-ctl fleet list

# Check active Canary OTA rollout progression
nexus-ctl ota status

# View recent explainable AI (XAI) feature attributions
nexus-ctl report scada
```

---

## 3. Launch the Digital Twin Cyber-Range (`sentinel-matrix`)

Because `sentinel-stack` harvested host binaries and libraries into `sentinel-matrix/shared/lib/`, you can launch the containerized simulation mesh immediately:

```bash
cd sentinel-matrix
make up
make tui
```
```

