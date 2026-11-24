#!/usr/bin/env bash
SCENARIO_SLUG="35_maglev_gap_collapse_guard"
SCENARIO_TITLE="Electrodynamic Maglev Levitation Gap Collapse Guard"
SCENARIO_DESC="High-speed magnetic flux & airgap clearance Nagumo barrier on EtherCAT/ShmRing."
CARTRIDGE="motion-guard"; SECTOR="HIGH_SPEED_RAIL"; SUBNET_PREFIX="10.240.135"; APPARATUS_HOST_PORT=18235
PRIMARY_PROTO_PORT=502; PRIMARY_ETHERTYPE="0x88A4"; DOMAIN_AE_MODEL="maglev_flux_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="cobot_ethercat_scope"; LAB_CAT_KEY="magnetic"; LAB_UNIT="mm"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("maglev_ecat.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "Bogie-Levitation-01|mag-gap-01.matrix.internal|INTEL_OPENVINO|Airgap-Eddy-Sensor-01|ETHERCAT_L2_SERVO|0|l2_raw|maglev_flux_ae.onnx|MAGNETIC|mm|10.0"
  "LSM-Propulsion-02|mag-lsm-02.matrix.internal|NVIDIA_TENSORRT|Linear-Sync-Motor-02|SHM_RING_MOTION|1|shm_ring|maglev_flux_ae.onnx|ELECTRICAL|Hz|240.0"
  "Trackside-Hotbox-03|mag-ir-03.matrix.internal|ROCKCHIP_RKNN|Guideway-IR-Monitor-03|SCADA_MODBUS_TCP|502|tcp|mobilenetv2-7.onnx|TEMPERATURE|C|48.0"
)
LAB_ATTACK_SPEC="maglev-flux-collapse|MAGLEV_GAP_COLLAPSE|Electrodynamic Levitation Gap Collapse|coherence_decay|drop_to_val|0.5"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
