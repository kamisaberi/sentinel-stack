#!/usr/bin/env bash
SCENARIO_SLUG="48_recycling_nir_polymer_sorter"
SCENARIO_TITLE="High-Speed Optical Polymer Sorting Belt (NIR Spectrometer)"
SCENARIO_DESC="< 10 us NIR classification sorting PET, HDPE & PVC on 10 m/s recycling belts."
CARTRIDGE="vision-guard"; SECTOR="RECYCLING_TECH"; SUBNET_PREFIX="10.240.148"; APPARATUS_HOST_PORT=18248
PRIMARY_PROTO_PORT=3956; DOMAIN_AE_MODEL="nir_polymer_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_conveyor_gige"; LAB_CAT_KEY="optical"; LAB_UNIT="FPS"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("nir_sorter.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "NIR-Hyperspec-01|nir-spec-01.matrix.internal|INTEL_OPENVINO|NIR-900nm-1700nm-01|GIGE_VISION_GVCP|3956|udp|squeezenet1.1-7.onnx|OPTICAL|FPS|200.0"
  "AirKnife-Bank-02|nir-jet-02.matrix.internal|NVIDIA_TENSORRT|PET-HDPE-Ejector-02|SHM_VISION_TOF|1|shm_ring|nir_polymer_ae.onnx|PRESSURE|bar|6.5"
  "Belt-Tachometer-03|nir-belt-03.matrix.internal|ROCKCHIP_RKNN|10ms-Belt-Encoder-03|SCADA_MODBUS_TCP|502|tcp|nir_polymer_ae.onnx|KINEMATIC|m/s|10.0"
)
LAB_ATTACK_SPEC="nir-calib-tamper|GIGE_WRITEREG|NIR Spectrometer Calibration Drift|impulse_shock|step_increase|50.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
