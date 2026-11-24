#!/usr/bin/env bash
SCENARIO_SLUG="36_airgapped_weapon_breach_guard"
SCENARIO_TITLE="Air-Gapped 4K Concealed Weapon & Perimeter Breach Guard"
SCENARIO_DESC="Zero-cloud RTSP/ONVIF 4K weapon detection & stream teardown prevention."
CARTRIDGE="vision-guard"; SECTOR="PHYSICAL_SECURITY"; SUBNET_PREFIX="10.240.136"; APPARATUS_HOST_PORT=18236
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="weapon_vision_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_weapon_rtsp"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("tinyyolov2-8.onnx=https://github.com/onnx/models/raw/main/validated/vision/object_detection_segmentation/tiny-yolov2/model/tinyyolov2-8.onnx")
PCAP_SOURCES=("rtsp_security.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Lobby-4K-RTSP-01|sec-cam-01.matrix.internal|INTEL_OPENVINO|Entrance-H265-Cam-01|RTSP_4K_VISION|8554|tcp|tinyyolov2-8.onnx|VISION|FPS|30.0"
  "Perimeter-ONVIF-02|sec-onvif-02.matrix.internal|NVIDIA_TENSORRT|Gate-PTZ-ONVIF-02|RTSP_4K_VISION|8554|tcp|weapon_vision_ae.onnx|VISION|FPS|30.0"
  "Turnstile-Access-03|sec-gate-03.matrix.internal|ROCKCHIP_RKNN|Mantrap-Lock-PLC-03|SCADA_MODBUS_TCP|502|tcp|weapon_vision_ae.onnx|NETWORK|ops|4.0"
)
LAB_ATTACK_SPEC="weapon-rtsp-teardown|RTSP_HIJACK|Perimeter Weapon Event & RTSP Stream Hijack|discrete_event|step_increase|60.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
