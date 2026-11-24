#!/usr/bin/env bash
SCENARIO_SLUG="33_bridge_micro_vibration_box"
SCENARIO_TITLE="Civil Infrastructure Bridge Micro-Vibration Anomaly Box"
SCENARIO_DESC="Piezoelectric accelerometer modal resonance & continual structural drift monitor."
CARTRIDGE="motion-guard"; SECTOR="CIVIL_INFRASTRUCTURE"; SUBNET_PREFIX="10.240.133"; APPARATUS_HOST_PORT=18233
PRIMARY_PROTO_PORT=502; DOMAIN_AE_MODEL="bridge_modal_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="cobot_ethercat_scope"; LAB_CAT_KEY="vibration"; LAB_UNIT="mm/s"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("bridge_vib.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "Span-Piezo-Array-01|span-01.matrix.internal|ROCKCHIP_RKNN|Deck-Modal-Piezo-01|VIBRATION_PROBE|15502|tcp|bridge_modal_ae.onnx|VIBRATION|mm/s|0.42"
  "Cable-Tension-02|cable-02.matrix.internal|INTEL_OPENVINO|Stay-Cable-Strain-02|SHM_RING_MOTION|1|shm_ring|bridge_modal_ae.onnx|KINEMATIC|kN|4200.0"
  "Pier-Tilt-Logger-03|pier-03.matrix.internal|NVIDIA_TENSORRT|Abutment-Tilt-03|SCADA_MODBUS_TCP|502|tcp|squeezenet1.1-7.onnx|GEOLOGICAL|deg|0.02"
)
LAB_ATTACK_SPEC="bridge-flutter-shift|MODAL_RESONANCE|Bridge Structural Eigenfrequency Drift|harmonic_sideband|harmonic_multiplier|3.1"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
