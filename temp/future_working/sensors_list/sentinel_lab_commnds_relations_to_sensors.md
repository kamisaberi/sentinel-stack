### Structural Analysis: Connecting `sentinel-lab` to the 570 Sensors

Currently, `sentinel-lab` provides **14 scientific research modules** (such as `hil`, `cbf`, `fdia`, `sidechannel`, `pqc`, and `fuzzer`). 

While these existing modules test the mathematical core (e.g., RK4 ODE stability, Control Barrier Functions $h(x) \ge 0$, and packet smuggling), testing **all 570 physical, silicon, optical, and chemical sensors** across your 80 domains requires mapping each sensor category to an exact validation action.

To systematically test the 570 sensors in `sentinel-matrix` digital twins without adding 570 separate CLI commands, we structure the verification into:
1. **How Existing `aryo lab` Commands Map to Specific Sensor Subsets.**
2. **The 10 Targeted New Research Commands to Add to `sentinel-lab`.**
3. **The Master Cross-Mapping Table (Command $\to$ Sensor Range $\to$ Validation Physics).**

---

### 1. How Existing `aryo lab` Commands Map to the 570 Sensors

Several existing commands can already validate specific sensor categories if supplied with the proper configuration:

* **`aryo lab hil` (Closed-Loop HIL RK4 Co-Simulator):**
  * **Sensors Covered:** **#035–#040** (Thermal/Cryo), **#052–#057** (Hydrodynamic Pressure), **#071–#077** (MHD & Magnetic), **#435–#441** (Geological DGR), **#528–#534** (SMR Passive Safety).
  * **Test Function:** Simulates continuous physics ODEs and checks if sensor readings correctly track system state under dynamic load changes.
* **`aryo lab cbf` (Control Barrier Function Verifier):**
  * **Sensors Covered:** **#046–#051** (Robotic F/T & Kinematics), **#058–#070** (Chemical Dosing & Water Treatment), **#116–#120** (Lyophilizer & Subsea), **#349–#355** (Autonomous Excavators), **#406–#412** (LNG Sloshing).
  * **Test Function:** Verifies that physical safety invariants $h(x) \ge 0$ clamp actuator write commands before physical limits are breached.
* **`aryo lab fdia` (Cross-Modal False Data Injection Orchestrator):**
  * **Sensors Covered:** **#018–#022** (Modbus/S7/IEC-104 Network Dissectors) paired against **#052, #073, #092, #149, #499** (Physical Flow, Pressure, Airspeed, Steer-by-Wire, GNSS-RTK).
  * **Test Function:** Spoofs network status while keeping physical sensors fixed to verify that the `ThreatCorrelator` detects the causal divergence and enforces in-kernel drops ($< 0.84\,\mu\text{s}$).
* **`aryo lab sidechannel` (Hardware Power/EM Side-Channel Analyzer):**
  * **Sensors Covered:** **#001–#007** (Microarchitectural PMU), **#027** (Near-Field Magnetic H-Probe), **#039** (Heat-Sink Thermal Leakage), **#118** (Keystroke Acoustic Vibration).
  * **Test Function:** Injects high-frequency CPU workloads and tests if covert electromagnetic, thermal, or acoustic data leaks can be measured.
* **`aryo lab fuzzer` & `stateful` (SCADA Smuggling & Stateful Fuzzers):**
  * **Sensors Covered:** **#018–#022** (Industrial Protocols), **#050** (Modbus RTU-in-TCP), **#057** (BACnet/SC), **#085–#091** (Radiation Monitors).
  * **Test Function:** Sends malformed function codes, corrupted IEEE 754 floats (NaN, denormals), and out-of-order packets to test dissector drop latencies.

---

### 2. The 10 New Research Commands to Add to `sentinel-lab`

To directly test, simulate, and calibrate the remaining specialized sensors (optics, radio frequency, acoustics, quantum standards, and extreme metallurgy), we propose adding **10 specialized lab actions**:

```text
========================================================================================================================
                          10 PROPOSED NEW COMMANDS FOR SENTINEL-LAB
========================================================================================================================
 1. aryo lab sensor-audit        Hardware Silicon, CPU PMU, Rowhammer & Supply-Rail Glitch Sentry
 2. aryo lab rf-sdr              RF Spectrum, Jamming, 1PPS Clock Jitter & Radar Cross-Section Evaluator
 3. aryo lab acoustic-tdoa       Ultrasonic Air-Gap Leak, Bearing Acoustic Emission & Gunshot TDOA Tester
 4. aryo lab fluid-shock         Water-Hammer Joukowsky, Cavitation & Deepwater High-Pressure APB Tester
 5. aryo lab space-avionics      Aviation Pitot/AoA, Star Tracker, Satellite SpacePackets & TVC Gimbals
 6. aryo lab quantum-metrology   SQUID Phase-Slip, Atom Interferometer & Cold-Atom Quantum Decoupler
 7. aryo lab power-grid          IEC 61850 SV/GOOSE, DLR Transmission Sag, HVDC Cables & Maglev Gaps
 8. aryo lab chemical-gas        Toxic Gas Plume Dispersion, Water Dosing & Electrolyzer Gas Crossover
 9. aryo lab fab-extreme         EUV Lithography Plasma, Wafer Laser Scatter & 3D Metal Melt-Pool Sensor
 10. aryo lab marine-subsea      Subsea Towed Hydrophones, UUV Acoustic Modems, CTD & Hull Tile Strain
========================================================================================================================
```

---

### 3. Master Cross-Mapping Table: Commands $\to$ Sensors (1 to 570)

The table below details every command, the exact sensor IDs it tests, the physical domain, and the mathematical test executed:

| Lab Action (`aryo lab <action>`) | Sensor IDs Covered | Domains Tested | Primary Threat / Physical Law Tested in `sentinel-matrix` |
| :--- | :--- | :--- | :--- |
| **`aryo lab sensor-audit`** *(New)* | **#001 – #014**<br>**#046** | Domain 01 (PMU/Silicon)<br>Domain 02 (PCB/Power)<br>Domain 11 (Rowhammer) | • ZenHammer / Rowhammer DRAM bit-flip injection<br>• VCC power rail brownout glitch transients ($\Delta V > 10\%$ in $<50\,\text{ns}$)<br>• Spectre/Meltdown LLC cache-miss rate thresholding ($< 3.5\%$) |
| **`aryo lab rf-sdr`** *(New)* | **#023 – #028**<br>**#128 – #134**<br>**#456 – #462** | Domain 04 (RF/GNSS)<br>Domain 19 (High-Energy Laser)<br>Domain 65 (HPEM/HPM) | • GPS/Galileo meaconing & 1PPS phase discontinuity ($> 100\,\text{ns}$)<br>• Wideband jamming RSSI elevation ($> 20\,\text{dB}$)<br>• High-Power Microwave (HPM) fast $dE/dt$ diode limiter trips ($< 1.0\,\text{ns}$) |
| **`aryo lab acoustic-tdoa`** *(New)* | **#029 – #034**<br>**#135 – #141**<br>**#521 – #527** | Domain 05 (Acoustics)<br>Domain 20 (Combustion)<br>Domain 74 (Submarine ASW) | • Ultrasonic covert air-gap data exfiltration ($20\text{--}100\,\text{kHz}$ FSK/OOK)<br>• Hyperbolic TDOA ballistic shockwave shooter localization ($< 15\,\text{ms}$)<br>• Gas turbine thermoacoustic flame rumble ($p' > 0.5\,\text{bar}$) |
| **`aryo lab fluid-shock`** *(New)* | **#052 – #057**<br>**#185 – #191**<br>**#256 – #262** | Domain 09 (Fluid/Pressure)<br>Domain 27 (Nuclear Voiding)<br>Domain 37 (Subsea Chokes) | • Joukowsky water-hammer valve pressure spike ($\Delta P = \rho c \Delta v$)<br>• Two-phase coolant boiling voiding ($\alpha \le 0.35$ in nuclear core)<br>• Subsea production choke acoustic sand erosion ($N_{\text{sand}} \propto V^{1.5}$) |
| **`aryo lab space-avionics`** *(New)* | **#092 – #098**<br>**#199 – #205**<br>**#221 – #227**<br>**#278 – #284**<br>**#313 – #320**<br>**#513 – #520** | Domain 14 (Avionics)<br>Domain 29 (Space Weather)<br>Domain 32 (Hypersonic TPS)<br>Domain 40 (ECLSS)<br>Domain 45 (Rocket TVC)<br>Domain 73 (Grid Fins) | • Dual AoA vane disagreement ($|\alpha_1 - \alpha_2| > 5.5^\circ$ MCAS defense)<br>• Spacecraft star tracker proton-streak and dazzler rejection ($< 15\,\mu\text{s}$)<br>• Re-entry ablative TPS recession and stagnation heat flux monitoring<br>• Rocket engine TVC hydraulic actuator gimbal tracking ($< 0.1^\circ$ error) |
| **`aryo lab quantum-metrology`** *(New)* | **#121 – #127**<br>**#321 – #327**<br>**#421 – #427**<br>**#060** | Domain 18 (Qubits/Metrology)<br>Domain 46 (Quantum Gravimetry)<br>Domain 60 (Fusion Plasma)<br>Domain 13 (NV Diamond) | • SQUID Josephson voltage standard microwave phase-slip detection<br>• BEC atom interferometer gravity gradient tensor verification ($\text{Tr}(\mathbf{T}) == 0$)<br>• Tokamak Mirnov coil MHD tearing mode growth rate ($\gamma > 0$ disruption alarm) |
| **`aryo lab power-grid`** *(New)* | **#078 – #084**<br>**#206 – #212**<br>**#292 – #298**<br>**#542 – #548**<br>**#563 – #570** | Domain 12 (High-Voltage)<br>Domain 30 (Power Quality)<br>Domain 42 (Transmission DLR)<br>Domain 77 (HVDC Cables)<br>Domain 80 (Maglev Levitation) | • 50th-order harmonic distortion injection ($\text{THD}_V \le 5.0\%$ IEEE 519)<br>• Transmission line dynamic sag catenary tension ($T = \frac{wL^2}{8S}$)<br>• Maglev eddy-current levitation gap decay rate ($\delta_{\text{gap}} = 10 \pm 2\,\text{mm}$) |
| **`aryo lab chemical-gas`** *(New)* | **#058 – #070**<br>**#156 – #162**<br>**#228 – #234**<br>**#556 – #562** | Domain 10 (Gas/Water)<br>Domain 23 (CBRN Biosecurity)<br>Domain 33 (Petrochem FCC)<br>Domain 79 (Electrolyzers) | • Water treatment pH & chlorine overdosing invariant ($6.5 \le \text{pH} \le 8.5$)<br>• Bio-aerosol laser-induced fluorescence (LIF) anthrax/ricin cloud detection<br>• Electrolyzer hydrogen-in-oxygen crossover explosion limit ($[H_2] \le 1.5\%$) |
| **`aryo lab fab-extreme`** *(New)* | **#106 – #112**<br>**#163 – #170**<br>**#213 – #220**<br>**#371 – #377**<br>**#442 – #448** | Domain 16 (Semiconductor Fab)<br>Domain 24 (Metallurgy)<br>Domain 31 (Metal 3D Print)<br>Domain 53 (EUV Lithography)<br>Domain 63 (Tandem Solar) | • RGA quadrupole vacuum chamber leak rate ($< 10^{-11}\,\text{mbar}\cdot\text{L/s}$)<br>• EUV molten tin droplet laser intercept precision ($\le 1.5\,\mu\text{m}$ at $50\text{ kHz}$)<br>• Metal 3D printing melt-pool pyrometry temperature ($1650^\circ\text{C} \text{--} 2200^\circ\text{C}$) |
| **`aryo lab marine-subsea`** *(New)* | **#099 – #105**<br>**#263 – #270**<br>**#363 – #370**<br>**#485 – #491** | Domain 15 (Oceanography)<br>Domain 38 (Autonomous Marine)<br>Domain 52 (Submarine Stealth)<br>Domain 69 (Deep-Sea Mining) | • CTD speed-of-sound acoustic refraction duct calculation<br>• Anechoic rubber tile hydrodynamic shear strain ($\gamma \le \gamma_{\text{debond}}$)<br>• Seafloor mining crawler abyssal pelagic clay sinkage ($z_{\text{sink}} \le 150\,\text{mm}$) |
| **`aryo lab hil`** *(Existing)* | **#035 – #040**<br>**#071 – #077**<br>**#435 – #441**<br>**#528 – #534** | Domain 06 (Thermal/Cryo)<br>Domain 11 (MHD/Magnetic)<br>Domain 62 (Geological DGR)<br>Domain 75 (SMR Passive) | • Arrhenius thermal runaway differential equations on battery packs<br>• Triaxial fluxgate magnetic dipole moment tracking ($\mathbf{B}(\mathbf{r}) \approx 0$)<br>• SMR thermosiphon natural circulation flow velocity ($v \propto \sqrt[3]{\dot{Q}\Delta z}$) |
| **`aryo lab cbf`** *(Existing)* | **#046 – #051**<br>**#116 – #120**<br>**#349 – #355**<br>**#406 – #412** | Domain 08 (Kinematics/Robots)<br>Domain 17 (Chemical/Bio)<br>Domain 50 (Heavy Machinery)<br>Domain 58 (LNG Sloshing) | • Cobot human contact force clamp ($\le 150\,\text{N}$ ISO/TS 15066 limit)<br>• Hydraulic excavator boom kinematic boundary ($h(\mathbf{x}) \ge 0$ avoidance)<br>• LNG tank cryogenic sloshing impact pressure boundary enforcement |
| **`aryo lab fdia`** *(Existing)* | **#018 – #022** paired with **#052, #073, #092, #149, #499** | Domain 03 (Network) vs Domain 09, 11, 14, 22, 71 | • Causal cross-modal deception: Network claims valve open, but pressure drops<br>• In-kernel eBPF drop executed in $< 0.84\,\mu\text{s}$ upon divergence detection |
| **`aryo lab sidechannel`** *(Existing)* | **#001 – #007**<br>**#027, #039, #118** | Domain 01 (PMU)<br>Domain 04 (EM H-Probe)<br>Domain 06 (Thermal)<br>Domain 17 (Acoustic) | • Microarchitectural IPC/cache miss correlation against CPU power draw<br>• CPU heat-sink thermal oscillation frequency scrambler validation |
| **`aryo lab fuzzer` / `stateful`** *(Existing)* | **#018 – #022**<br>**#050, #057** | Domain 03 (Network Protocols)<br>Domain 11, Domain 12 | • Differential parser desynchronization (Gateway verdict vs Mock PLC state)<br>• Subnormal IEEE 754 float pattern injection (`NaN`, denormals, divide-by-zero) |

---

### In Accordance with Rules 1, 2, and 4:

* **Rule 1 & 2 Note:** No code in `sentinel-lab` or `sentinel-stack` has been altered. This blueprint establishes the architectural mapping.
* **Next Action:** When you are ready to implement any of these 10 new research commands, please share:
  1. `sentinel-stack/src/aryo.cpp`
  2. The entry point of `sentinel-lab` (e.g. `sentinel-lab/src/main.cpp` or `sentinel-lab/cli/main.cpp`).
* We will then follow the exact instruction and roadmap process, implement the command handler, and provide the complete build commands.

Which of the 10 new lab commands would you like to implement first?