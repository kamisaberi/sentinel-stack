#!/usr/bin/env bash
SCENARIO_SLUG="03_bess_thermal_runaway"
SCENARIO_TITLE="Battery Energy Storage (BESS) Thermal Runaway Guard"
SCENARIO_DESC="Cross-modal lithium-ion cell impedance vs thermal runaway early warning."
CARTRIDGE="ics-guard"; SECTOR="ENERGY_STORAGE"; SUBNET_PREFIX="10.240.103"; APPARATUS_HOST_PORT=18203
PRIMARY_PROTO_PORT=502; DOMAIN_AE_MODEL="bess_thermal_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="flir_thermal"; LAB_CAT_KEY="temperature"; LAB_UNIT="C"; LAB_MIN=20.0; LAB_MAX=160.0; LAB_SAFE_LOW=22.0; LAB_SAFE_HIGH=65.0
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("modbus_bess.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "BESS-Rack-BMS-01|bms-01.matrix.internal|INTEL_OPENVINO|LiIon-Cell-BMS-01|MODBUS_BMS|502|tcp|bess_thermal_ae.onnx|TEMPERATURE|C|34.2"
  "BESS-Thermal-FLIR-02|bess-flir-02.matrix.internal|NVIDIA_TENSORRT|Container-IR-Cam-02|FLIR_RTSP_STREAM|8554|tcp|mobilenetv2-7.onnx|TEMPERATURE|C|36.5"
  "BESS-Inverter-PCS-03|bess-pcs-03.matrix.internal|ROCKCHIP_RKNN|PCS-Impedance-03|GRID_PAC3200_METER|15501|tcp|bess_thermal_ae.onnx|ELECTRICAL|mOhm|1.8"
)
LAB_ATTACK_SPEC="bess-thermal-surge|BESS_RUNAWAY|BESS Cell Thermal Runaway Surge|caustic_ramp|step_increase|65.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
