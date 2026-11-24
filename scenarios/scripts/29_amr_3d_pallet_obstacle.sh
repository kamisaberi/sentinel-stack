#!/usr/bin/env bash
SCENARIO_SLUG="29_amr_3d_pallet_obstacle"
SCENARIO_TITLE="Warehouse AMR 3D Pallet & Obstacle Avoidance Engine"
SCENARIO_DESC="Zero-copy POSIX ShmRing (MOT1) + 3D LiDAR spatial obstacle avoidance."
CARTRIDGE="motion-guard"; SECTOR="WAREHOUSE_AMR"; SUBNET_PREFIX="10.240.129"; APPARATUS_HOST_PORT=18229
PRIMARY_PROTO_PORT=2368; DOMAIN_AE_MODEL="amr_lidar_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="amr_shm_lidar"; LAB_CAT_KEY="lidar"; LAB_UNIT="m"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("amr_dds.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "AMR-LiDAR-3D-01|amr-lidar-01.matrix.internal|NVIDIA_TENSORRT|Ouster-3D-LiDAR-01|SHM_RING_MOTION|1|shm_ring|amr_lidar_ae.onnx|LIDAR|m|3.4"
  "AMR-DDS-Planner-02|amr-dds-02.matrix.internal|INTEL_OPENVINO|CycloneDDS-Path-02|SHM_RING_MOTION|1|shm_ring|amr_lidar_ae.onnx|KINEMATIC|m/s|1.8"
  "AMR-Fork-Actuator-03|amr-fork-03.matrix.internal|ROCKCHIP_RKNN|Pallet-Lift-CAN-03|SOCKETCAN_CANFD|513|can|mobilenetv2-7.onnx|PRESSURE|bar|110.0"
)
LAB_ATTACK_SPEC="amr-lidar-blind|LIDAR_SPOOF_OBSTACLE|AMR 3D LiDAR Obstacle Blind Vector|flatline_freeze|drop_to_val|0.1"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
