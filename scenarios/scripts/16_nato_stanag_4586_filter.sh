#!/usr/bin/env bash
SCENARIO_SLUG="16_nato_stanag_4586_filter"
SCENARIO_TITLE="NATO STANAG 4586 Tactical UAS Telemetry Filter"
SCENARIO_DESC="Sub-120 ns DLI/VSM waypoint & steering command anti-replay and kinematic gate."
CARTRIDGE="ccsds-guard"; SECTOR="TACTICAL_UAS"; SUBNET_PREFIX="10.240.116"; APPARATUS_HOST_PORT=18216
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="stanag_4586_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="formation_hud"; LAB_CAT_KEY="avionics"; LAB_UNIT="knots"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("stanag_dli.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "GCS-VSM-Gateway-01|vsm-01.matrix.internal|INTEL_OPENVINO|STANAG-DLI-Router-01|STANAG_4586|50050|udp|stanag_4586_ae.onnx|AVIONICS|knots|115.0"
  "UAS-FlightCtrl-02|uav-fc-02.matrix.internal|NVIDIA_TENSORRT|Airframe-IMU-Gyro-02|KINEMATIC_IMU|50051|udp|stanag_4586_ae.onnx|KINEMATIC|deg/s|8.5"
  "Payload-EOIR-03|uav-eoir-03.matrix.internal|ROCKCHIP_RKNN|EOIR-Gimbal-03|FLIR_RTSP_STREAM|8554|tcp|mobilenetv2-7.onnx|VISION|FPS|30.0"
)
LAB_ATTACK_SPEC="stanag-waypoint-teleport|GPS_TELEPORT|5km STANAG 4586 Waypoint Teleport|flatline_freeze|drop_to_val|12.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
