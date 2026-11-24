#!/usr/bin/env bash
SCENARIO_SLUG="46_agtech_precision_weed_sprayer"
SCENARIO_TITLE="AgTech Tractor Ultra-Speed Precision Weed Sprayer"
SCENARIO_DESC="60 FPS downward camera segmentation triggering micro-spray solenoids in < 2 ms."
CARTRIDGE="vision-guard"; SECTOR="AGTECH_PRECISION"; SUBNET_PREFIX="10.240.146"; APPARATUS_HOST_PORT=18246
PRIMARY_PROTO_PORT=3956; DOMAIN_AE_MODEL="agtech_weed_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_conveyor_gige"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("boom_gige.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Boom-DownCam-01|ag-cam-01.matrix.internal|ROCKCHIP_RKNN|60FPS-Row-Camera-01|GIGE_VISION_GVCP|3956|udp|mobilenetv2-7.onnx|VISION|FPS|60.0"
  "MicroSpray-Nozzle-02|ag-noz-02.matrix.internal|INTEL_OPENVINO|ISOBUS-Solenoid-02|SOCKETCAN_CANFD|513|can|agtech_weed_ae.onnx|PRESSURE|bar|3.2"
  "Tractor-GNSS-Speed-03|ag-gnss-03.matrix.internal|NVIDIA_TENSORRT|25kmh-Boom-Speed-03|SHM_VISION_TOF|1|shm_ring|agtech_weed_ae.onnx|KINEMATIC|m/s|6.9"
)
LAB_ATTACK_SPEC="spray-overdose-flood|NOZZLE_LOCK_ON|Solenoid Lock-On Herbicide Flood|caustic_ramp|step_increase|90.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
