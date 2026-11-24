#!/usr/bin/env bash
SCENARIO_SLUG="34_mining_canfd_steering_governor"
SCENARIO_TITLE="Underground Mining Vehicle CAN-FD Steering & Torque Governor"
SCENARIO_DESC="SocketCAN / AF_UNIX CAN-FD arbitration ID filter & steering-angle safety clamp."
CARTRIDGE="motion-guard"; SECTOR="UNDERGROUND_MINING"; SUBNET_PREFIX="10.240.134"; APPARATUS_HOST_PORT=18234
PRIMARY_PROTO_PORT=513; DOMAIN_AE_MODEL="mining_canfd_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="mining_canfd_bus"; LAB_CAT_KEY="kinematic"; LAB_UNIT="deg"
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("can_steer.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "SteerByWire-CAN-01|steer-can-01.matrix.internal|INTEL_OPENVINO|Articulated-Steer-01|SOCKETCAN_CANFD|513|can|mining_canfd_ae.onnx|KINEMATIC|deg|8.4"
  "Traction-Inverter-02|trac-02.matrix.internal|NVIDIA_TENSORRT|Electric-Wheel-Torque-02|SOCKETCAN_CANFD|514|can|mining_canfd_ae.onnx|ELECTRICAL|Nm|110.0"
  "Tunnel-V2X-Modem-03|v2x-03.matrix.internal|ROCKCHIP_RKNN|LeakyFeeder-V2X-03|SHM_RING_MOTION|1|shm_ring|resnet18-v1-7.onnx|RF_EM|dBm|-75.0"
)
LAB_ATTACK_SPEC="canfd-steer-hijack|STEER_BY_WIRE_HIJACK|68-Deg CAN-FD Articulated Steer Hijack|impulse_shock|step_increase|28.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
