#!/usr/bin/env bash
SCENARIO_SLUG="41_construction_ppe_compliance"
SCENARIO_TITLE="Construction Site Multi-Camera PPE & Hazard Zone Box"
SCENARIO_DESC="8-stream local RTSP inference auditing hardhats, harnesses & crane exclusion zones."
CARTRIDGE="vision-guard"; SECTOR="CONSTRUCTION_SAFETY"; SUBNET_PREFIX="10.240.141"; APPARATUS_HOST_PORT=18241
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="ppe_compliance_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_weapon_rtsp"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("tinyyolov2-8.onnx=https://github.com/onnx/models/raw/main/validated/vision/object_detection_segmentation/tiny-yolov2/model/tinyyolov2-8.onnx")
PCAP_SOURCES=("ppe_rtsp.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Crane-Boom-Cam-01|ppe-crane-01.matrix.internal|ROCKCHIP_RKNN|TowerCrane-RTSP-01|RTSP_4K_VISION|8554|tcp|tinyyolov2-8.onnx|VISION|FPS|30.0"
  "Scaffold-Gate-02|ppe-scaff-02.matrix.internal|INTEL_OPENVINO|Harness-Detector-02|SHM_VISION_TOF|1|shm_ring|ppe_compliance_ae.onnx|VISION|FPS|30.0"
  "Site-Siren-Relay-03|ppe-siren-03.matrix.internal|NVIDIA_TENSORRT|Safety-Alarm-PLC-03|SCADA_MODBUS_TCP|502|tcp|ppe_compliance_ae.onnx|INDUSTRIAL_CPS|ops|1.0"
)
LAB_ATTACK_SPEC="ppe-zone-intrusion|PPE_VIOLATION|Crane Swing Hazard Zone Unprotected Entry|discrete_event|step_increase|70.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
