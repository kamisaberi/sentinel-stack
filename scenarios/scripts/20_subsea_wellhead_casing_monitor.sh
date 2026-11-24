#!/usr/bin/env bash
SCENARIO_SLUG="20_subsea_wellhead_casing_monitor"
SCENARIO_TITLE="Subsea Wellhead Annular Casing Burst Monitor"
SCENARIO_DESC="Autonomous underwater ROV acoustic sonar & annular casing pressure boundary."
CARTRIDGE="ccsds-guard"; SECTOR="OFFSHORE_ROV"; SUBNET_PREFIX="10.240.120"; APPARATUS_HOST_PORT=18220
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="rov_subsea_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="radar_360"; LAB_CAT_KEY="subsea"; LAB_UNIT="bar"
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("rov_sonar.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "ROV-Multibeam-Sonar-01|rov-sonar-01.matrix.internal|NVIDIA_TENSORRT|Acoustic-Sonar-01|MULTIBEAM_SONAR|50050|udp|rov_subsea_ae.onnx|SUBSEA|bar|140.0"
  "ROV-Cathodic-Probe-02|rov-cp-02.matrix.internal|INTEL_OPENVINO|Anode-Potential-02|SUBSEA_TELEMETRY|50051|udp|rov_subsea_ae.onnx|ELECTRICAL|mV|-950.0"
  "ROV-HD-Umbilical-03|rov-hd-03.matrix.internal|ROCKCHIP_RKNN|Umbilical-HD-Link-03|FLIR_RTSP_STREAM|8554|tcp|resnet18-v1-7.onnx|VISION|FPS|30.0"
)
LAB_ATTACK_SPEC="subsea-casing-burst|SUBSEA_APB_BURST|Wellhead Annular Casing Burst Spike|impulse_shock|step_increase|110.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
