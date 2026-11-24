#!/usr/bin/env bash
SCENARIO_SLUG="40_robotic_bin_picking_3d"
SCENARIO_TITLE="Robotic 3D Bin-Picking INT8 Pose Estimation Controller"
SCENARIO_DESC="Structured-light 3D camera GigE point-cloud pick coordinate verification (< 20 us)."
CARTRIDGE="vision-guard"; SECTOR="FACTORY_LOGISTICS"; SUBNET_PREFIX="10.240.140"; APPARATUS_HOST_PORT=18240
PRIMARY_PROTO_PORT=3956; DOMAIN_AE_MODEL="binpick_pose_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_conveyor_gige"; LAB_CAT_KEY="optical"; LAB_UNIT="um"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("binpick_gige.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Photoneo-3DCam-01|bin-3d-01.matrix.internal|INTEL_OPENVINO|Structured-Light-3D-01|GIGE_VISION_GVCP|3956|udp|squeezenet1.1-7.onnx|OPTICAL|um|12.0"
  "Pose-Estimator-02|bin-pose-02.matrix.internal|NVIDIA_TENSORRT|6DoF-INT8-Solver-02|SHM_VISION_TOF|1|shm_ring|binpick_pose_ae.onnx|KINEMATIC|deg|2.0"
  "Vacuum-Gripper-03|bin-grip-03.matrix.internal|ROCKCHIP_RKNN|Vacuum-Suction-PLC-03|SCADA_MODBUS_TCP|502|tcp|binpick_pose_ae.onnx|PRESSURE|kPa|-75.0"
)
LAB_ATTACK_SPEC="pose-calibration-drift|POSE_POISONING|Adversarial 6DoF Pick Coordinate Drift|impulse_shock|step_increase|40.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
