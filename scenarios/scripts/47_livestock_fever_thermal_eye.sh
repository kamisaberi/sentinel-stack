#!/usr/bin/env bash
SCENARIO_SLUG="47_livestock_fever_thermal_eye"
SCENARIO_TITLE="Livestock Biosecurity Herd Fever & Lameness Thermal Eye"
SCENARIO_DESC="LWIR infrared dairy herd fever & gait anomaly tracking at water troughs."
CARTRIDGE="vision-guard"; SECTOR="AGTECH_LIVESTOCK"; SUBNET_PREFIX="10.240.147"; APPARATUS_HOST_PORT=18247
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="livestock_lwir_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_hipaa_fall_shm"; LAB_CAT_KEY="temperature"; LAB_UNIT="C"
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("barn_lwir.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Trough-LWIR-Cam-01|barn-ir-01.matrix.internal|ROCKCHIP_RKNN|LWIR-Ocular-Temp-01|RTSP_4K_VISION|8554|tcp|resnet18-v1-7.onnx|TEMPERATURE|C|38.6"
  "Gait-Kinematics-02|barn-gait-02.matrix.internal|INTEL_OPENVINO|Lameness-Stride-02|SHM_VISION_TOF|1|shm_ring|livestock_lwir_ae.onnx|KINEMATIC|m/s|1.1"
  "Sort-Gate-RFID-03|barn-gate-03.matrix.internal|NVIDIA_TENSORRT|Biosecurity-Gate-03|SCADA_MODBUS_TCP|502|tcp|livestock_lwir_ae.onnx|INDUSTRIAL_CPS|ops|6.0"
)
LAB_ATTACK_SPEC="herd-fever-outbreak|FEVER_SPIKE|Herd Elevated Core Temperature Detection|caustic_ramp|step_increase|41.5"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
