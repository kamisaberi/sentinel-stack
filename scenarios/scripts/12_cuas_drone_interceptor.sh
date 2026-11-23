#!/usr/bin/env bash
SCENARIO_SLUG="12_cuas_drone_interceptor"
SCENARIO_TITLE="Counter-UAS Optical / RF Drone Interceptor Box"
SCENARIO_DESC="Multi-sensor GigE Vision + VITA 49 SDR hostile drone tracking & intercept guard."
CARTRIDGE="ccsds-guard"; SECTOR="DEFENSE_CUAS"; SUBNET_PREFIX="10.240.112"; APPARATUS_HOST_PORT=18212
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="cuas_interceptor_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="radar_360"; LAB_CAT_KEY="rf_em"; LAB_UNIT="dBm"
ONNX_SOURCES=("tinyyolov2-8.onnx=https://github.com/onnx/models/raw/main/validated/vision/object_detection_segmentation/tiny-yolov2/model/tinyyolov2-8.onnx")
PCAP_SOURCES=("http_cuas.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "CUAS-SDR-VITA49-01|cuas-sdr-01.matrix.internal|INTEL_OPENVINO|VITA49-RF-Receiver-01|TACTICAL_RADIO_SDR|50050|udp|cuas_interceptor_ae.onnx|RF_EM|dBm|-78.0"
  "CUAS-EOIR-Gimbal-02|cuas-eoir-02.matrix.internal|NVIDIA_TENSORRT|4K-EOIR-Tracker-02|GIGE_VISION|3956|udp|tinyyolov2-8.onnx|VISION|FPS|60.0"
  "Interceptor-C2-03|cuas-c2-03.matrix.internal|ROCKCHIP_RKNN|Interceptor-Link-03|STANAG_4586|50050|udp|cuas_interceptor_ae.onnx|AVIONICS|m/s|32.0"
)
LAB_ATTACK_SPEC="cuas-rf-jam|HPM_SURGE|Broadband Drone RF Control Spoof|coherence_decay|step_increase|60.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
