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

