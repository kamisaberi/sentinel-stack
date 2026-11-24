#!/usr/bin/env bash
SCENARIO_SLUG="30_surgical_boundary_motion_clamp"
SCENARIO_TITLE="Surgical Robotics TSN & Anatomical Boundary Motion Clamp"
SCENARIO_DESC="Sub-ms SO_TIMESTAMPING TSN 802.1Qbv jitter guard + 3D artery Keep-Out-Zone CBF."
CARTRIDGE="motion-guard"; SECTOR="MEDTECH_SURGICAL"; SUBNET_PREFIX="10.240.130"; APPARATUS_HOST_PORT=18230
PRIMARY_PROTO_PORT=502; PRIMARY_ETHERTYPE="0x88A4"; DOMAIN_AE_MODEL="surgical_tsn_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="cobot_ethercat_scope"; LAB_CAT_KEY="kinematic"; LAB_UNIT="mm"
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("surgical_tsn.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Master-Surgeon-Console-01|surg-con-01.matrix.internal|INTEL_OPENVINO|Haptic-Teleop-TSN-01|ETHERCAT_L2_SERVO|0|l2_raw|surgical_tsn_ae.onnx|KINEMATIC|mm|12.0"
  "Instrument-Arm-KOZ-02|surg-arm-02.matrix.internal|NVIDIA_TENSORRT|Artery-KOZ-CBF-02|SHM_RING_MOTION|1|shm_ring|surgical_tsn_ae.onnx|KINEMATIC|mm|4.5"
  "Endoscope-Stereo-03|surg-endo-03.matrix.internal|ROCKCHIP_RKNN|4K-Endoscope-03|RTSP_4K_VISION|8554|tcp|resnet18-v1-7.onnx|VISION|FPS|60.0"
)
LAB_ATTACK_SPEC="surgical-koz-breach|SURGICAL_KOZ_BREACH|Anatomical Artery Keep-Out-Zone Intrusion|impulse_shock|step_increase|35.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
