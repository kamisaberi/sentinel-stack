#!/usr/bin/env bash
SCENARIO_SLUG="05_drinking_water_dosing_guard"
SCENARIO_TITLE="Drinking Water Chemical Dosing Safety Guard"
SCENARIO_DESC="Control Barrier Function interlock preventing chlorine/caustic soda overdosing."
CARTRIDGE="ics-guard"; SECTOR="WATER_UTILITY"; SUBNET_PREFIX="10.240.105"; APPARATUS_HOST_PORT=18205
PRIMARY_PROTO_PORT=502; DOMAIN_AE_MODEL="water_dosing_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="reactor_core"; LAB_CAT_KEY="chemical"; LAB_UNIT="pH"; LAB_MIN=0.0; LAB_MAX=14.0; LAB_SAFE_LOW=6.5; LAB_SAFE_HIGH=8.5
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("modbus_water.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "Intake-Pump-RTU-01|intake-01.matrix.internal|INTEL_OPENVINO|Raw-Water-Flow-01|SCADA_MODBUS_TCP|502|tcp|water_dosing_ae.onnx|PRESSURE|LPM|420.0"
  "NaOH-Dosing-PLC-02|dosing-02.matrix.internal|NVIDIA_TENSORRT|Caustic-Dosing-Pump-02|SCADA_MODBUS_TCP|502|tcp|water_dosing_ae.onnx|CHEMICAL|pH|7.3"
  "Outflow-Chlorine-03|outflow-03.matrix.internal|ROCKCHIP_RKNN|Residual-Cl2-Analyzer-03|CHEMICAL_PROBE|15502|tcp|squeezenet1.1-7.onnx|CHEMICAL|ppm|1.8"
)
LAB_ATTACK_SPEC="oldsmar-naoh-surge|OLDSMAR_POISONING|Oldsmar Caustic Soda Setpoint Overdose|caustic_ramp|step_increase|4.5"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
