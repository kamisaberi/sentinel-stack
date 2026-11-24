#!/usr/bin/env bash
SCENARIO_SLUG="37_conveyor_micro_defect_sorter"
SCENARIO_TITLE="200 FPS GigE Vision Conveyor Micro-Defect Sorter"
SCENARIO_DESC="GenICam/GigE Vision GVCP (:3956) write-lock & sub-ms pneumatic ejector."
CARTRIDGE="vision-guard"; SECTOR="INDUSTRIAL_QA"; SUBNET_PREFIX="10.240.137"; APPARATUS_HOST_PORT=18237
PRIMARY_PROTO_PORT=3956; DOMAIN_AE_MODEL="conveyor_defect_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_conveyor_gige"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("gige_line.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "GigE-LineScan-Cam-01|gige-cam-01.matrix.internal|INTEL_OPENVINO|Basler-GigE-200FPS-01|GIGE_VISION_GVCP|3956|udp|mobilenetv2-7.onnx|VISION|FPS|200.0"
  "Pneumatic-Ejector-02|eject-02.matrix.internal|NVIDIA_TENSORRT|AirJet-Diverter-02|SHM_VISION_TOF|1|shm_ring|conveyor_defect_ae.onnx|OPTICAL|um|5.0"
  "Belt-Encoder-PLC-03|belt-03.matrix.internal|ROCKCHIP_RKNN|Conveyor-Encoder-03|SCADA_MODBUS_TCP|502|tcp|conveyor_defect_ae.onnx|KINEMATIC|m/s|2.4"
)
LAB_ATTACK_SPEC="gige-exposure-tamper|GIGE_WRITEREG|GigE GVCP Exposure Register Tampering|impulse_shock|step_increase|45.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
