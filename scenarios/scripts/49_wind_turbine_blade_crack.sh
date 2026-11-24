#!/usr/bin/env bash
SCENARIO_SLUG="49_wind_turbine_blade_crack"
SCENARIO_TITLE="Wind Turbine Blade Composite Delamination & Crack Box"
SCENARIO_DESC="Acoustic Emission (AES) + nacelle blade vision detecting composite fatigue."
CARTRIDGE="vision-guard"; SECTOR="CLEAN_ENERGY_WIND"; SUBNET_PREFIX="10.240.149"; APPARATUS_HOST_PORT=18249
PRIMARY_PROTO_PORT=8554; DOMAIN_AE_MODEL="wind_blade_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="vision_weapon_rtsp"; LAB_CAT_KEY="vibration"; LAB_UNIT="mm/s"
ONNX_SOURCES=("densenet-12.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/densenet-121/model/densenet-12.onnx")
PCAP_SOURCES=("wind_scada.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "Blade-Acoustic-AES-01|wind-aes-01.matrix.internal|ROCKCHIP_RKNN|Composite-Delam-AES-01|SHM_VISION_TOF|1|shm_ring|wind_blade_ae.onnx|VIBRATION|mm/s|2.1"
  "Nacelle-Zoom-Cam-02|wind-cam-02.matrix.internal|INTEL_OPENVINO|Blade-Tip-4K-Cam-02|RTSP_4K_VISION|8554|tcp|densenet-12.onnx|VISION|FPS|30.0"
  "Pitch-Feather-PLC-03|wind-plc-03.matrix.internal|NVIDIA_TENSORRT|Blade-Pitch-Feather-03|SCADA_MODBUS_TCP|502|tcp|wind_blade_ae.onnx|ELECTRICAL|MW|8.5"
)
LAB_ATTACK_SPEC="blade-delam-fatigue|BLADE_DELAMINATION|Composite Blade Structural Crack Shock|harmonic_sideband|harmonic_multiplier|3.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
