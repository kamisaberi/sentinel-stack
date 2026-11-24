#!/usr/bin/env bash
SCENARIO_SLUG="43_smart_city_adaptive_traffic"
SCENARIO_TITLE="Smart City Adaptive Traffic Signal & NTCIP Controller"
SCENARIO_DESC="Local V4L2/RTSP intersection object detection + NTCIP green-conflict guard."
CARTRIDGE="vision-guard"; SECTOR="SMART_CITIES_ITS"; SUBNET_PREFIX="10.240.143"; APPARATUS_HOST_PORT=18243
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="traffic_ntcip_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_weapon_rtsp"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("tinyyolov2-8.onnx=https://github.com/onnx/models/raw/main/validated/vision/object_detection_segmentation/tiny-yolov2/model/tinyyolov2-8.onnx")
PCAP_SOURCES=("its_ntcip.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Intersection-Cam-01|its-cam-01.matrix.internal|ROCKCHIP_RKNN|NEMA-Intersection-Cam-01|RTSP_4K_VISION|8554|tcp|tinyyolov2-8.onnx|VISION|FPS|30.0"
  "NTCIP-Signal-Ctrl-02|its-sig-02.matrix.internal|INTEL_OPENVINO|Conflict-Monitor-MMU-02|SCADA_MODBUS_TCP|502|tcp|traffic_ntcip_ae.onnx|INDUSTRIAL_CPS|ops|10.0"
  "V2X-RSU-Beacon-03|its-rsu-03.matrix.internal|NVIDIA_TENSORRT|DSRC-CV2X-RSU-03|SHM_VISION_TOF|1|shm_ring|traffic_ntcip_ae.onnx|RF_EM|dBm|-72.0"
)
LAB_ATTACK_SPEC="signal-all-green|NTCIP_CONFLICT|Hostile All-Green Signal Phase Injection|discrete_event|step_increase|85.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
