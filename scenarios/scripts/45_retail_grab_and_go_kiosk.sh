#!/usr/bin/env bash
SCENARIO_SLUG="45_retail_grab_and_go_kiosk"
SCENARIO_TITLE="Zero-Cloud Frictionless Grab-and-Go Micro-Store Kiosk"
SCENARIO_DESC="Ceiling camera grid + shelf weight fusion with zero customer facial storage."
CARTRIDGE="vision-guard"; SECTOR="RETAIL_LOGISTICS"; SUBNET_PREFIX="10.240.145"; APPARATUS_HOST_PORT=18245
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="kiosk_shelf_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_hipaa_fall_shm"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("kiosk_stream.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Ceiling-Grid-Cam-01|kiosk-cam-01.matrix.internal|ROCKCHIP_RKNN|RAMOnly-Ceiling-Track-01|SHM_VISION_TOF|1|shm_ring|squeezenet1.1-7.onnx|VISION|FPS|30.0"
  "Shelf-Weight-Mat-02|kiosk-wt-02.matrix.internal|INTEL_OPENVINO|Shelf-Force-Array-02|SCADA_MODBUS_TCP|502|tcp|kiosk_shelf_ae.onnx|PRESSURE|g|1250.0"
  "Exit-Gate-NFC-03|kiosk-exit-03.matrix.internal|NVIDIA_TENSORRT|Checkout-Exit-Gate-03|RTSP_4K_VISION|8554|tcp|kiosk_shelf_ae.onnx|NETWORK|ops|12.0"
)
LAB_ATTACK_SPEC="kiosk-shelf-tamper|PRIVACY_RETENTION|Unauthorized Facial Retention or Shelf Spoof|flatline_freeze|drop_to_val|0.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
