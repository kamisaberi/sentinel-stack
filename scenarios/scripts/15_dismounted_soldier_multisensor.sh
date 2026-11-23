#!/usr/bin/env bash
SCENARIO_SLUG="15_dismounted_soldier_multisensor"
SCENARIO_TITLE="Dismounted Soldier Tactical Multi-Sensor Fusion Box"
SCENARIO_DESC="Low-power thermal, acoustic & tactical IP ATAK mesh edge fusion node."
CARTRIDGE="ccsds-guard"; SECTOR="TACTICAL_MILITARY"; SUBNET_PREFIX="10.240.115"; APPARATUS_HOST_PORT=18215
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="soldier_fusion_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="flir_thermal"; LAB_CAT_KEY="rf_em"; LAB_UNIT="dBm"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("tactical_ip.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Soldier-LWIR-Helmet-01|lwir-01.matrix.internal|ROCKCHIP_RKNN|Helmet-LWIR-Cam-01|FLIR_RTSP_STREAM|8554|tcp|squeezenet1.1-7.onnx|VISION|FPS|30.0"
  "Shot-Spot-Acoustic-02|acoustic-02.matrix.internal|INTEL_OPENVINO|TDOA-Gunshot-Mic-02|ACOUSTIC_ARRAY|50051|udp|soldier_fusion_ae.onnx|VIBRATION|dB|65.0"
  "ATAK-MANET-Radio-03|manet-03.matrix.internal|NVIDIA_TENSORRT|MANET-Mesh-Node-03|TACTICAL_RADIO_SDR|50050|udp|soldier_fusion_ae.onnx|RF_EM|dBm|-80.0"
)
LAB_ATTACK_SPEC="manet-byzantine-spoof|MESH_BYZANTINE|Byzantine Blue-Force Tracker Spoof|harmonic_sideband|harmonic_multiplier|2.4"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
