#!/usr/bin/env bash
SCENARIO_SLUG="50_subway_platform_crowd_eye"
SCENARIO_TITLE="Subway Platform Crowd Surge & Track-Intrusion Eye"
SCENARIO_DESC="Real-time optical flow crowd crush & yellow-line fall detection on local NPU."
CARTRIDGE="vision-guard"; SECTOR="MASS_TRANSIT"; SUBNET_PREFIX="10.240.150"; APPARATUS_HOST_PORT=18250
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="subway_crowd_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_weapon_rtsp"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("tinyyolov2-8.onnx=https://github.com/onnx/models/raw/main/validated/vision/object_detection_segmentation/tiny-yolov2/model/tinyyolov2-8.onnx")
PCAP_SOURCES=("transit_cctv.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Platform-Edge-Cam-01|sub-cam-01.matrix.internal|INTEL_OPENVINO|YellowLine-OpticalFlow-01|RTSP_4K_VISION|8554|tcp|tinyyolov2-8.onnx|VISION|FPS|30.0"
  "Concourse-Density-02|sub-conc-02.matrix.internal|ROCKCHIP_RKNN|Crowd-Density-Grid-02|SHM_VISION_TOF|1|shm_ring|subway_crowd_ae.onnx|VISION|FPS|30.0"
  "Platform-Door-PSD-03|sub-psd-03.matrix.internal|NVIDIA_TENSORRT|ScreenDoor-Interlock-03|SCADA_MODBUS_TCP|502|tcp|subway_crowd_ae.onnx|INDUSTRIAL_CPS|ops|12.0"
)
LAB_ATTACK_SPEC="platform-crowd-surge|CROWD_SURGE|Platform Crowd Crush & Track-Edge Intrusion|caustic_ramp|step_increase|85.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
