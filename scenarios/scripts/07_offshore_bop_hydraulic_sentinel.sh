#!/usr/bin/env bash
SCENARIO_SLUG="07_offshore_bop_hydraulic_sentinel"
SCENARIO_TITLE="Offshore Drilling Blowout Preventer (BOP) Hydraulic Sentinel"
SCENARIO_DESC="Real-time subsea MUX acoustic & shear-ram hydraulic pressure boundary guard."
CARTRIDGE="ics-guard"; SECTOR="OFFSHORE_OIL_GAS"; SUBNET_PREFIX="10.240.107"; APPARATUS_HOST_PORT=18207
PRIMARY_PROTO_PORT=502; DOMAIN_AE_MODEL="bop_hydraulic_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="reactor_core"; LAB_CAT_KEY="subsea"; LAB_UNIT="bar"; LAB_MIN=0.0; LAB_MAX=350.0; LAB_SAFE_LOW=40.0; LAB_SAFE_HIGH=220.0
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("modbus_bop.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "Subsea-BluePod-01|bluepod-01.matrix.internal|INTEL_OPENVINO|BOP-ShearRam-Valve-01|SCADA_MODBUS_TCP|502|tcp|bop_hydraulic_ae.onnx|SUBSEA|bar|185.0"
  "Mux-Acoustic-02|mux-02.matrix.internal|NVIDIA_TENSORRT|Riser-Mux-Acoustic-02|SUBSEA_TELEMETRY|15502|tcp|bop_hydraulic_ae.onnx|PRESSURE|PSI|2900.0"
  "Driller-HMI-03|driller-03.matrix.internal|ROCKCHIP_RKNN|Topside-Accumulator-03|SCADA_MODBUS_TCP|502|tcp|resnet18-v1-7.onnx|PRESSURE|bar|205.0"
)
LAB_ATTACK_SPEC="bop-apb-burst|SUBSEA_APB_BURST|Annular Casing Overpressure Surge|impulse_shock|step_increase|110.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
