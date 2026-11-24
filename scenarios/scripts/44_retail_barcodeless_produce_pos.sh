#!/usr/bin/env bash
SCENARIO_SLUG="44_retail_barcodeless_produce_pos"
SCENARIO_TITLE="Barcodeless High-Speed Produce Recognition POS"
SCENARIO_DESC="Top-down RGB scale camera classification in < 50 ms on local edge NPU."
CARTRIDGE="vision-guard"; SECTOR="SMART_RETAIL"; SUBNET_PREFIX="10.240.144"; APPARATUS_HOST_PORT=18244
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="produce_pos_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_conveyor_gige"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("pos_checkout.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Scale-Overhead-Cam-01|pos-cam-01.matrix.internal|INTEL_OPENVINO|TopDown-RGB-Scale-01|SHM_VISION_TOF|1|shm_ring|mobilenetv2-7.onnx|VISION|FPS|30.0"
  "LoadCell-Scale-02|pos-wt-02.matrix.internal|ROCKCHIP_RKNN|Digital-LoadCell-02|SCADA_MODBUS_TCP|502|tcp|produce_pos_ae.onnx|PRESSURE|g|840.0"
  "POS-Terminal-03|pos-term-03.matrix.internal|NVIDIA_TENSORRT|Local-SKU-Ledger-03|RTSP_4K_VISION|8554|tcp|produce_pos_ae.onnx|NETWORK|ms|18.0"
)
LAB_ATTACK_SPEC="pos-weight-spoof|POS_TICKET_SWITCH|Scale Load-Cell vs Visual SKU Mismatch|discrete_event|step_increase|42.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
