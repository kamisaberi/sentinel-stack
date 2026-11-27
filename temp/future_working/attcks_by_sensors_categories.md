Here is the complete **Multi-Category Cyber-Physical Attack Matrix**.

Because real-world physical and hardware exploits propagate across boundaries—a network injection or electromagnetic pulse causes physical cavitation, thermal runaway, or mechanical fracture—attacks are cross-mapped to **all primary and collateral categories** they impact.

---

### The 24 Master Sensor & Physics Categories
```text
automotive      bioprocess      electrical      industrial_cps  magnetic        microarch       nuclear
pcb_power       propulsion      rf_em           temperature     avionics        chemical        geological
kinematic       metallurgy      network         optical         pressure        quantum         semiconductor
subsea          vibration
```

---

# Master Cyber-Physical Attack-to-Category Matrix (28 Core Attacks)

```text
========================================================================================================================
                          ARYORITHM 28-ATTACK CYBER-PHYSICAL THREAT TAXONOMY
========================================================================================================================
```

### 1. `stuxnet-resonance` (Resonant Rotor Fatigue & Telemetry Replay)
* **Description:** Injects malicious Variable Frequency Drive (VFD) frequencies into rotating equipment (uranium centrifuges, high-speed turbines) to dwell in mechanical resonance zones while spoofing normal telemetry to operators.
* **Primary Target Categories:** `nuclear`, `vibration`, `industrial_cps`
* **Collateral Affected Categories:** `kinematic`, `network`, `temperature`
* **Target Sensors Tripped:** #031 (Vibration Velocity), #124 (Centrifuge Jeffcott Rotor Resonance), #018 (Modbus Write).

---

### 2. `water-hammer` (Joukowsky Hydraulic Shock Injection)
* **Description:** Maliciously snaps shut high-pressure pipeline motor-operated valves or trips pumping stations, generating supersonic pressure shockwaves ($\Delta P = \rho c \Delta v$) that rupture welds and burst pipes.
* **Primary Target Categories:** `pressure`, `industrial_cps`, `subsea`
* **Collateral Affected Categories:** `vibration`, `network`, `chemical`
* **Target Sensors Tripped:** #052 (High-Frequency Piezoresistive Pressure), #034 (Acoustic Cavitation), #028 (Pipeline Cavitation).

---

### 3. `rowhammer` (DRAM Electromagnetic Coupling Bit-Flip)
* **Description:** Repeatedly accesses adjacent physical DRAM rows millions of times per second (ZenHammer/Rowhammer), leaking electrical charge across microscopic capacitors to flip bits in kernel memory or bypass hypervisor sandboxes.
* **Primary Target Categories:** `microarch`, `pcb_power`
* **Collateral Affected Categories:** `network`, `semiconductor`
* **Target Sensors Tripped:** #004 (Rowhammer Bank Activations), #002 (LLC Cache Miss Rate), #006 (Page Fault Rate).

---

### 4. `voltage-glitch` (Power-Rail Brownout Fault Injection)
* **Description:** Shorts the CPU core $V_{CC}$ rail for $< 50\,\text{ns}$ or modulates external ground pins to corrupt instruction register fetches, skipping cryptographic verification or password branches (`CMP -> JNE`).
* **Primary Target Categories:** `pcb_power`, `microarch`
* **Collateral Affected Categories:** `semiconductor`, `electrical`
* **Target Sensors Tripped:** #008 (VCC Brownout Transient ADC), #009 (Oscillator Jitter), #022 (Hardware Brownout Sentry).

---

### 5. `gnss-spoof` (GPS/Galileo Meaconing & Phase Discontinuity)
* **Description:** Re-broadcasts delayed or artificially calculated satellite signals to desynchronize electrical grid synchrophasor clocks (1PPS), drift marine navigation, or trick drone geofences.
* **Primary Target Categories:** `rf_em`, `electrical`, `avionics`
* **Collateral Affected Categories:** `network`, `subsea`
* **Target Sensors Tripped:** #023 (GNSS $C/N_0$ Flat Variance), #024 (1PPS Phase Error $> 100\,\text{ns}$), #025 (GNSS Sentry).

---

### 6. `hpm-surge` (High-Power Microwave Directed-Energy Burnout)
* **Description:** Blasts gigawatt pulsed microwave radiation into equipment cabinets, coupling high-voltage transients into circuit traces to destroy front-end RF receiver diodes and semiconductor gates.
* **Primary Target Categories:** `rf_em`, `pcb_power`, `semiconductor`
* **Collateral Affected Categories:** `electrical`, `avionics`
* **Target Sensors Tripped:** #456 (Waveguide Fast D-Dot $dE/dt$), #011 (EMP Crowbar Sentry), #026 (Antenna VSWR).

---

### 7. `oldsmar-poisoning` (Stoichiometric Caustic Chemical Overdose)
* **Description:** Overrides chemical dosing pump setpoints on water treatment networks (e.g. sodium hydroxide/caustic soda from $100\,\text{ppm} \to 11{,}100\,\text{ppm}$) to release corrosive, poisonous water into municipal mains.
* **Primary Target Categories:** `chemical`, `industrial_cps`
* **Collateral Affected Categories:** `network`, `pressure`
* **Target Sensors Tripped:** #061 (Inline Water pH), #062 (Free Chlorine Residual), #040 (Chemical Dosing Guard).

---

### 8. `scada-smuggling` (Differential Parser Desynchronization)
* **Description:** Exploits inconsistencies between security gateway parsers and legacy PLC firmware (COTP fragmentation, Modbus function code chaining) so that the gateway sees benign traffic while the PLC executes destructive writes.
* **Primary Target Categories:** `network`, `industrial_cps`
* **Collateral Affected Categories:** `microarch`
* **Target Sensors Tripped:** #018 (Modbus Dissector), #019 (S7Comm TPKT), #050 (Modbus RTU-in-TCP).

---

### 9. `bess-thermal-runaway` (Lithium-Ion Exothermic Dendrite Collapse)
* **Description:** Manipulates Battery Management System (BMS) cell balancing and charging contactors, inducing high-current localized heating that triggers irreversible Arrhenius exothermic decomposition.
* **Primary Target Categories:** `temperature`, `electrical`, `chemical`
* **Collateral Affected Categories:** `pressure`, `pcb_power`, `industrial_cps`
* **Target Sensors Tripped:** #035 (Radiometric Thermal LWIR), #040 (Cell Thermal Expansion), #009 (BESS Arrhenius ODE).

---

### 10. `aoa-freeze` (Angle-of-Attack Single-Point Sensor Spoofing)
* **Description:** Spoofs or freezes resolving signals on aircraft AoA vanes, simulating an aerodynamic stall and forcing automated flight control systems (like MCAS) into uncommanded nose-down dives.
* **Primary Target Categories:** `avionics`, `kinematic`
* **Collateral Affected Categories:** `pressure`, `network`
* **Target Sensors Tripped:** #093 (Dual AoA Disparity $> 5.5^\circ$), #092 (Pitot Dynamic Pressure), #021 (Flight Override Sentry).

---

### 11. `tvc-gimbal-lock` (Rocket Thrust Vector Control Hydraulic Jam)
* **Description:** Injects anomalous hydraulic servo commands into launch vehicle or sounding rocket gimbal actuators, forcing the engine nozzle to its physical mechanical stops and causing vehicle breakup.
* **Primary Target Categories:** `propulsion`, `avionics`, `kinematic`
* **Collateral Affected Categories:** `pressure`, `network`
* **Target Sensors Tripped:** #313 (TVC Actuator LVDT Resolver), #519 (Gimbal Flex-Joint Sensor), #518 (Landing High-G Accelerometer).

---

### 12. `cobot-crush` (ISO 13849 Safety-Zone Override & Admittance Surge)
* **Description:** Overwrites joint torque limits or disables optical safety scanners on collaborative robots, causing high-mass arm payloads to strike human operators with crushing forces exceeding $150\,\text{N}$.
* **Primary Target Categories:** `kinematic`, `industrial_cps`
* **Collateral Affected Categories:** `network`, `vibration`
* **Target Sensors Tripped:** #048 (6-Axis F/T Load Cell), #285 (Safety Laser Scanner OSSD), #016 (Cobot PL-e Governor).

---

### 13. `steer-by-wire-hijack` (Automotive CAN-FD Torque Injection)
* **Description:** Injects spoofed torque and steering angle frames into the internal vehicle network (CAN-FD / FlexRay), forcing unintended steering wheel movement or disabling electronic stability control at speed.
* **Primary Target Categories:** `automotive`, `kinematic`, `network`
* **Collateral Affected Categories:** `vibration`, `pcb_power`
* **Target Sensors Tripped:** #149 (Dual Steer-by-Wire Torque Disparity), #151 (Magnetoresistive Wheel Speed), #005 (CAN-FD Sentry).

---

### 14. `h2-crossover` (Electrolyzer Membrane Perforation & Explosive Mixing)
* **Description:** Throttles differential pressure across alkaline or PEM electrolyzer cell stacks, forcing hydrogen gas across the polymer membrane into the oxygen chamber and forming an explosive gas mix ($> 4\%\,H_2$).
* **Primary Target Categories:** `chemical`, `pressure`, `electrical`
* **Collateral Affected Categories:** `temperature`, `industrial_cps`
* **Target Sensors Tripped:** #556 (Hydrogen-in-Oxygen Thermal Conductivity), #558 (Cell Voltage Monitor), #051 (Hydrogen Fueling Guard).

---

### 15. `nuclear-dnb` (Core Flow Blockage & Departure from Nucleate Boiling)
* **Description:** Manipulates main coolant pump VFDs or misaligns control rod banks to induce localized boiling voiding in high-flux fuel assemblies, causing steam insulation and fuel cladding melt.
* **Primary Target Categories:** `nuclear`, `temperature`, `pressure`
* **Collateral Affected Categories:** `chemical`, `electrical`, `vibration`
* **Target Sensors Tripped:** #185 (Wire-Mesh Tomography Void Fraction), #188 (CET Subcooling Margin), #186 (HJTC Probe).

---

### 16. `subsea-apb-burst` (Annular Pressure Buildup Well Casing Rupture)
* **Description:** Manipulates subsea choke valves and production rates, transferring reservoir heat into trapped annular brine fluids until thermal expansion pressures crush or burst the well casing.
* **Primary Target Categories:** `subsea`, `pressure`, `temperature`
* **Collateral Affected Categories:** `geological`, `metallurgy`
* **Target Sensors Tripped:** #054 (Subsea APB Casing Stress), #260 (Wellhead Annulus Quartz Resonator), #061 (Subsea APB Sentry).

---

### 17. `euv-laser-miss` (Molten Tin Droplet Laser Misalignment)
* **Description:** Alters the timing or position of the pre-pulse laser in EUV lithography, causing the main $\text{CO}_2$ laser pulse to miss the molten tin droplet and strike the vacuum chamber wall, vaporizing multi-layer mirrors.
* **Primary Target Categories:** `semiconductor`, `optical`, `temperature`
* **Collateral Affected Categories:** `pressure`, `metallurgy`
* **Target Sensors Tripped:** #371 (Tin Droplet Position Error), #374 (EUV Collector Reflectivity), #095 (EUV Flashing Guard).

---

### 18. `casting-breakout` (Continuous Steel Casting Meniscus Collapse)
* **Description:** Tampers with stopper-rod hydraulic actuators or mold oscillation frequencies, causing liquid steel meniscus levels to fluctuate wildly until the solidified shell tears, spilling $1{,}500^\circ\text{C}$ liquid steel.
* **Primary Target Categories:** `metallurgy`, `temperature`, `kinematic`
* **Collateral Affected Categories:** `pressure`, `industrial_cps`
* **Target Sensors Tripped:** #168 (Mold Level Radar Velocity), #166 (Liquid Steel Pyrometer), #112 (Casting Invariant).

---

### 19. `grid-harmonic-resonance` (Inverter Harmonic Injection & Capacitor Flashover)
* **Description:** Re-programs grid-tied solar/wind inverter switching firmware to inject sub-synchronous or 50th-order harmonic currents, exciting LC resonance in utility capacitor banks until they explode.
* **Primary Target Categories:** `electrical`
* **Collateral Affected Categories:** `temperature`, `network`
* **Target Sensors Tripped:** #206 (Voltage THD 50th-Harmonic), #207 (Flicker $P_{\text{st}}$), #210 (Negative Sequence Unbalance).

---

### 20. `rocof-blackout` (Synthetic Inertia Droop & Frequency Collapse)
* **Description:** Simultaneously steps down active power output on utility-scale battery inverters during peak demand, triggering steep rate-of-change-of-frequency ($|df/dt| > 2\,\text{Hz/s}$) that trips protective relays across the grid.
* **Primary Target Categories:** `electrical`, `industrial_cps`
* **Collateral Affected Categories:** `network`, `magnetic`
* **Target Sensors Tripped:** #212 (ROCOF Frequency Derivative), #080 (Surge Arrester $I_{3r}$), #040 (Microgrid VSG Guard).

---

### 21. `quantum-dephase` (Microwave Resonant SQUID & Qubit Perturbation)
* **Description:** Broadcasts targeted stray microwave frequencies into cryogenic dilution refrigerators, exciting Josephson junctions and NV-diamond centers to collapse qubit superposition and drift quantum voltage standards.
* **Primary Target Categories:** `quantum`, `rf_em`, `temperature`
* **Collateral Affected Categories:** `magnetic`, `semiconductor`
* **Target Sensors Tripped:** #060 (NV Diamond Spin Dephasing), #121 (Transmon Qubit Readout Phase), #124 (Ramsey Fringe Visibility).

---

### 22. `gravimeter-spoof` (Synthetic Gravity Gradient Tensor Inversion)
* **Description:** Injects phase noise or laser frequency jitter into cold-atom / BEC atom interferometers, generating synthetic gravitational anomalies that break Laplace tensor invariants ($\text{Tr}(\mathbf{T}) \ne 0$) and misdirect autonomous navigation.
* **Primary Target Categories:** `quantum`, `kinematic`
* **Collateral Affected Categories:** `optical`, `avionics`
* **Target Sensors Tripped:** #326 (Gravity Gradient Tensor Trace), #321 (BEC Atom Interferometer Phase), #323 (ODT Power Stability).

---

### 23. `airgap-acoustic-leak` (Ultrasonic Motherboard Covert Exfiltration)
* **Description:** Malware modulates CPU core workloads or fans to produce ultrasonic acoustic whine ($20\text{--}100\,\text{kHz}$) through power coils, transmitting stolen data across air-gapped security boundaries to nearby microphones.
* **Primary Target Categories:** `vibration`, `microarch`
* **Collateral Affected Categories:** `temperature`, `pcb_power`
* **Target Sensors Tripped:** #029 (Air-Gap Ultrasonic Microphone), #039 (Heat-Sink Thermal Oscillation), #002 (Acoustic Air-Gap Guard).

---

### 24. `torpedo-door-override` (Submarine Muzzle/Breech Interlock Defeat)
* **Description:** Bypasses safety interlocking signals to simultaneously unlatch both the inner breech door and outer sea muzzle door of a torpedo tube, flooding the submarine torpedo room under ocean hydrostatic pressure.
* **Primary Target Categories:** `subsea`, `pressure`, `kinematic`
* **Collateral Affected Categories:** `network`, `electrical`
* **Target Sensors Tripped:** #367 (Torpedo Muzzle/Breech Proximity Interlock), #101 (Subsea Quartz Depth), #368 (Hull Gland Compression).

---

### 25. `maglev-gap-collapse` (Eddy-Current Suspension Demagnetization)
* **Description:** Manipulates electromagnet chopping inverter PWM on high-speed Maglev trains, reducing the levitation air-gap from $10\,\text{mm} \to 0\,\text{mm}$ and causing vehicle skids to crash into guideway rails at $500\,\text{km/h}$.
* **Primary Target Categories:** `magnetic`, `electrical`, `kinematic`
* **Collateral Affected Categories:** `vibration`, `temperature`
* **Target Sensors Tripped:** #563 (Maglev Eddy-Current Air-Gap), #566 (Landing Skid Thermopile), #568 (Ground-Fault CT).

---

### 26. `dam-cavitation-gouge` (Spillway Bernoulli Vapor Shock Collapse)
* **Description:** Maliciously misconfigures radial spillway gates to throttle aeration vents during flood discharge, dropping water pressure below vapor pressure and producing cavitation shockwaves that gouge through reinforced concrete.
* **Primary Target Categories:** `pressure`, `industrial_cps`, `geological`
* **Collateral Affected Categories:** `vibration`, `network`
* **Target Sensors Tripped:** #057 (Dam Spillway Cavitation Index $\sigma$), #034 (Acoustic Cavitation Transducer), #044 (Dam Siphon Sentry).

---

### 27. `cell-lysis-shear` (Biopharmaceutical Perfusion Membrane Rupture)
* **Description:** Spikes peristaltic pump speeds in continuous perfusion bioreactors, exceeding critical fluid shear stress limits ($\tau_{\text{shear}} > 1.5\,\text{Pa}$) and causing mammalian cell lysis that contaminates entire oncology drug batches.
* **Primary Target Categories:** `bioprocess`, `pressure`, `chemical`
* **Collateral Affected Categories:** `temperature`, `network`
* **Target Sensors Tripped:** #113 (Bio-Impedance Cell Spectroscopy), #079 (Bioreactor Shear Lysis Sentry), #053 (Coriolis Meter).

---

### 28. `tokamak-disruption` (Fusion Plasma Mirnov Tearing Mode Growth)
* **Description:** Tamers with center-solenoid heating or gas puffing valves in magnetic confinement fusion reactors, triggering resistive tearing modes ($\gamma > 0$) that dump gigajoules of plasma thermal energy onto divertor tiles.
* **Primary Target Categories:** `nuclear`, `magnetic`, `temperature`
* **Collateral Affected Categories:** `electrical`, `pressure`, `quantum`
* **Target Sensors Tripped:** #421 (Mirnov Poloidal Coil Pick-up), #423 (Divertor Heat Flux Langmuir Probe), #424 (Plasma Current Quench Rate).

---

# Reverse Index: Attacks by Category

| Category | Associated Cyber-Physical Attacks |
| :--- | :--- |
| **`network`** | `scada-smuggling`, `stuxnet-resonance`, `water-hammer`, `oldsmar-poisoning`, `rowhammer`, `gnss-spoof`, `aoa-freeze`, `tvc-gimbal-lock`, `cobot-crush`, `steer-by-wire-hijack`, `grid-harmonic-resonance`, `rocof-blackout`, `torpedo-door-override`, `dam-cavitation-gouge`, `cell-lysis-shear` |
| **`microarch`** | `rowhammer`, `voltage-glitch`, `scada-smuggling`, `airgap-acoustic-leak` |
| **`pcb_power`** | `voltage-glitch`, `rowhammer`, `hpm-surge`, `bess-thermal-runaway`, `steer-by-wire-hijack`, `airgap-acoustic-leak` |
| **`rf_em`** | `gnss-spoof`, `hpm-surge`, `quantum-dephase` |
| **`vibration`** | `stuxnet-resonance`, `water-hammer`, `cobot-crush`, `steer-by-wire-hijack`, `nuclear-dnb`, `airgap-acoustic-leak`, `maglev-gap-collapse`, `dam-cavitation-gouge` |
| **`temperature`** | `bess-thermal-runaway`, `nuclear-dnb`, `subsea-apb-burst`, `euv-laser-miss`, `casting-breakout`, `grid-harmonic-resonance`, `quantum-dephase`, `airgap-acoustic-leak`, `maglev-gap-collapse`, `cell-lysis-shear`, `tokamak-disruption`, `stuxnet-resonance` |
| **`pressure`** | `water-hammer`, `oldsmar-poisoning`, `aoa-freeze`, `tvc-gimbal-lock`, `h2-crossover`, `nuclear-dnb`, `subsea-apb-burst`, `euv-laser-miss`, `casting-breakout`, `torpedo-door-override`, `dam-cavitation-gouge`, `cell-lysis-shear`, `tokamak-disruption` |
| **`electrical`** | `grid-harmonic-resonance`, `rocof-blackout`, `voltage-glitch`, `gnss-spoof`, `hpm-surge`, `bess-thermal-runaway`, `h2-crossover`, `nuclear-dnb`, `maglev-gap-collapse`, `torpedo-door-override`, `tokamak-disruption` |
| **`magnetic`** | `maglev-gap-collapse`, `rocof-blackout`, `quantum-dephase`, `tokamak-disruption` |
| **`kinematic`** | `stuxnet-resonance`, `aoa-freeze`, `tvc-gimbal-lock`, `cobot-crush`, `steer-by-wire-hijack`, `casting-breakout`, `gravimeter-spoof`, `torpedo-door-override`, `maglev-gap-collapse` |
| **`chemical`** | `oldsmar-poisoning`, `bess-thermal-runaway`, `h2-crossover`, `nuclear-dnb`, `cell-lysis-shear`, `water-hammer` |
| **`industrial_cps`**| `stuxnet-resonance`, `water-hammer`, `oldsmar-poisoning`, `cobot-crush`, `dam-cavitation-gouge`, `bess-thermal-runaway`, `casting-breakout`, `rocof-blackout` |
| **`nuclear`** | `stuxnet-resonance`, `nuclear-dnb`, `tokamak-disruption` |
| **`avionics`** | `aoa-freeze`, `tvc-gimbal-lock`, `gnss-spoof`, `hpm-surge`, `gravimeter-spoof` |
| **`propulsion`** | `tvc-gimbal-lock` |
| **`automotive`** | `steer-by-wire-hijack` |
| **`subsea`** | `subsea-apb-burst`, `torpedo-door-override`, `water-hammer`, `gnss-spoof` |
| **`semiconductor`**| `euv-laser-miss`, `rowhammer`, `voltage-glitch`, `hpm-surge`, `quantum-dephase` |
| **`metallurgy`** | `casting-breakout`, `subsea-apb-burst`, `euv-laser-miss` |
| **`quantum`** | `quantum-dephase`, `gravimeter-spoof`, `tokamak-disruption` |
| **`optical`** | `euv-laser-miss`, `gravimeter-spoof` |
| **`bioprocess`** | `cell-lysis-shear` |
| **`geological`** | `dam-cavitation-gouge`, `subsea-apb-burst` |

---

### Architectural Connection to `sentinel-matrix` and `sentinel-lab`

In our test execution pipeline, each attack is triggered via the unified syntax:
```bash
aryo lab <module> --attack <attack_name>
```

When an attack is launched, the following loop executes:
1. **`sentinel-lab` Harness:** Injects the synthetic sensor corruption or anomalous telemetry stream across the designated categories.
2. **`sentinel-matrix` Physics Engine:** Updates the continuous RK4 ODEs (thermodynamic, hydrodynamic, kinematic, or electrical) to model the physical consequences.
3. **`blackbox-sentinel` (ThreatCorrelator):** Audits the cross-category invariant (e.g. checking if `network` commands match `pressure` or `temperature` physics).
4. **`blackbox-essential` (eBPF Kernel Ring):** Drops the offending network packets or kills the process in **$< 0.84\,\mu\text{s}$**, certifying full active defense.