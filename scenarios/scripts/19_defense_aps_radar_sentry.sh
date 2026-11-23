#!/usr/bin/env bash
SCENARIO_SLUG="19_defense_aps_radar_sentry"
SCENARIO_TITLE="Armored Vehicle Active Protection System (APS) Radar Sentry"
SCENARIO_DESC="Millimeter-wave ballistic trajectory verification & countermeasure interlock (< 15 ms)."
CARTRIDGE="ccsds-guard"; SECTOR="DEFENSE_ARMOR"; SUBNET_PREFIX="10.240.119"; APPARATUS_HOST_PORT=18219
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="aps_ballistic_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="radar_360"; LAB_CAT_KEY="rf_em"; LAB_UNIT="m/s"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("aps_radar.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "MMW-Radar-Quadrant-01|aps-mmw-01.matrix.internal|NVIDIA_TENSORRT|77GHz-MMW-Array-01|MMW_RADAR|50050|udp|aps_ballistic_ae.onnx|RF_EM|dBm|-65.0"
  "Ballistic-Solver-02|aps-solv-02.matrix.internal|INTEL_OPENVINO|Track-Kalman-02|STANAG_4586|50051|udp|aps_ballistic_ae.onnx|KINEMATIC|m/s|290.0"
  "Launcher-Interlock-03|aps-fire-03.matrix.internal|ROCKCHIP_RKNN|Countermeasure-Gate-03|ACTUATOR_AIRGAP|50052|udp|mobilenetv2-7.onnx|AVIONICS|ms|2.1"
)
LAB_ATTACK_SPEC="aps-false-fire|APS_SPOOF|Spoofed Radar Phantom Countermeasure Trigger|impulse_shock|step_increase|80.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
