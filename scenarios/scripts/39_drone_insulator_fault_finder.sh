#!/usr/bin/env bash
SCENARIO_SLUG="39_drone_insulator_fault_finder"
SCENARIO_TITLE="Power Line Inspection Drone Thermal Insulator Fault Finder"
SCENARIO_DESC="Onboard radiometric LWIR + 4K classification flagging hairline HV insulator cracks."
CARTRIDGE="vision-guard"; SECTOR="UTILITY_DRONE_QA"; SUBNET_PREFIX="10.240.139"; APPARATUS_HOST_PORT=18239
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="insulator_crack_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_weapon_rtsp"; LAB_CAT_KEY="vision"; LAB_UNIT="C"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("drone_rtsp.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Drone-4K-Optical-01|insul-4k-01.matrix.internal|NVIDIA_TENSORRT|4K-Gimbal-Cam-01|RTSP_4K_VISION|8554|tcp|mobilenetv2-7.onnx|VISION|FPS|30.0"
  "Drone-LWIR-Pod-02|insul-ir-02.matrix.internal|INTEL_OPENVINO|Radiometric-LWIR-02|SHM_VISION_TOF|1|shm_ring|insulator_crack_ae.onnx|TEMPERATURE|C|42.0"
  "Corona-UV-Sensor-03|insul-uv-03.matrix.internal|ROCKCHIP_RKNN|Corona-Discharge-03|GIGE_VISION_GVCP|3956|udp|insulator_crack_ae.onnx|OPTICAL|cnt|3.0"
)
LAB_ATTACK_SPEC="corona-thermal-hotspot|INSULATOR_FLASHOVER|HV Insulator Corona & Thermal Hotspot|caustic_ramp|step_increase|75.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
