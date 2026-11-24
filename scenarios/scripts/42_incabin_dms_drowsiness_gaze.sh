#!/usr/bin/env bash
SCENARIO_SLUG="42_incabin_dms_drowsiness_gaze"
SCENARIO_TITLE="In-Cabin Automotive NIR DMS Drowsiness & Gaze Eye"
SCENARIO_DESC="MIPI-CSI2/V4L2 NIR camera PERCLOS drowsiness & head-pose distraction (< 5W)."
CARTRIDGE="vision-guard"; SECTOR="AUTOMOTIVE_DMS"; SUBNET_PREFIX="10.240.142"; APPARATUS_HOST_PORT=18242
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="dms_perclos_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="vision_hipaa_fall_shm"; LAB_CAT_KEY="vision"; LAB_UNIT="%"
ONNX_SOURCES=("emotion-ferplus-8.onnx=https://github.com/onnx/models/raw/main/validated/vision/body_analysis/emotion_ferplus/model/emotion-ferplus-8.onnx")
PCAP_SOURCES=("dms_can.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "NIR-Column-Cam-01|dms-nir-01.matrix.internal|ROCKCHIP_RKNN|MIPI-NIR-Face-01|SHM_VISION_TOF|1|shm_ring|emotion-ferplus-8.onnx|VISION|FPS|60.0"
  "Gaze-PERCLOS-ECU-02|dms-ecu-02.matrix.internal|INTEL_OPENVINO|PERCLOS-HeadPose-02|SHM_VISION_TOF|1|shm_ring|dms_perclos_ae.onnx|KINEMATIC|deg|4.0"
  "ADAS-Haptic-BCM-03|dms-bcm-03.matrix.internal|NVIDIA_TENSORRT|Steering-Haptic-CAN-03|SOCKETCAN_CANFD|513|can|dms_perclos_ae.onnx|AUTOMOTIVE|pct|8.0"
)
LAB_ATTACK_SPEC="dms-microsleep|DRIVER_DROWSINESS|Driver Micro-Sleep PERCLOS > 20% Event|caustic_ramp|step_increase|38.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
