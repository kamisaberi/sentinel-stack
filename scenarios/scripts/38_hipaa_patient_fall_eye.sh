#!/usr/bin/env bash
SCENARIO_SLUG="38_hipaa_patient_fall_eye"
SCENARIO_TITLE="HIPAA RAM-Only Inpatient 3D ToF Fall Detection Eye"
SCENARIO_DESC="0-byte persistent disk retention via POSIX /dev/shm (VIS1) volatile memory purge."
CARTRIDGE="vision-guard"; SECTOR="HEALTHCARE_PRIVACY"; SUBNET_PREFIX="10.240.138"; APPARATUS_HOST_PORT=18238
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="hipaa_fall_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_hipaa_fall_shm"; LAB_CAT_KEY="vision"; LAB_UNIT="FPS"
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("hipaa_hl7.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Ward-ToF-Sensor-01|tof-ward-01.matrix.internal|ROCKCHIP_RKNN|3D-ToF-RamRing-01|SHM_VISION_TOF|1|shm_ring|hipaa_fall_ae.onnx|VISION|FPS|30.0"
  "Nurse-Call-HL7-02|hl7-02.matrix.internal|INTEL_OPENVINO|HL7-Alert-Bridge-02|RTSP_4K_VISION|8554|tcp|resnet18-v1-7.onnx|NETWORK|ops|2.0"
  "Privacy-Zeroizer-03|purge-03.matrix.internal|NVIDIA_TENSORRT|RAM-Zeroizer-Guard-03|SHM_VISION_TOF|1|shm_ring|hipaa_fall_ae.onnx|MICROARCH|B|0.0"
)
LAB_ATTACK_SPEC="hipaa-disk-retention|HIPAA_RETENTION|Unauthorized Patient Frame Disk Retention|flatline_freeze|drop_to_val|0.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
