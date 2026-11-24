#!/usr/bin/env bash
SCENARIO_SLUG="31_haul_truck_collision_preventer"
SCENARIO_TITLE="Autonomous Mining Haul Truck Collision Preventer"
SCENARIO_DESC="FMCW radar + CANopen emergency air-brake interlock for 300-ton haul trucks."
CARTRIDGE="motion-guard"; SECTOR="MINING_AUTOMATION"; SUBNET_PREFIX="10.240.131"; APPARATUS_HOST_PORT=18231
PRIMARY_PROTO_PORT=513; DOMAIN_AE_MODEL="haul_radar_can_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="mining_canfd_bus"; LAB_CAT_KEY="kinematic"; LAB_UNIT="m"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("mining_can.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Haul-FMCW-Radar-01|haul-rad-01.matrix.internal|NVIDIA_TENSORRT|77GHz-Forward-Radar-01|SHM_RING_MOTION|1|shm_ring|haul_radar_can_ae.onnx|LIDAR|m|28.0"
  "AirBrake-CANopen-02|haul-brk-02.matrix.internal|INTEL_OPENVINO|Pneumatic-Brake-CAN-02|SOCKETCAN_CANFD|513|can|haul_radar_can_ae.onnx|PRESSURE|bar|8.5"
  "Cab-Thermal-Cam-03|haul-cam-03.matrix.internal|ROCKCHIP_RKNN|BlindSpot-LWIR-03|RTSP_4K_VISION|8554|tcp|squeezenet1.1-7.onnx|VISION|FPS|30.0"
)
LAB_ATTACK_SPEC="haul-brake-cut|BRAKE_OVERRIDE|CANopen Air-Brake Suppression Spoof|flatline_freeze|drop_to_val|0.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
