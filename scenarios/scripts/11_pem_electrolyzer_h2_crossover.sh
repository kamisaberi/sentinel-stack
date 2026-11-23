#!/usr/bin/env bash
SCENARIO_SLUG="11_pem_electrolyzer_h2_crossover"
SCENARIO_TITLE="PEM Electrolyzer Hydrogen Membrane Crossover Guard"
SCENARIO_DESC="Green hydrogen electrolyzer stack differential pressure & LEL safety barrier."
CARTRIDGE="ics-guard"; SECTOR="CLEAN_ENERGY_H2"; SUBNET_PREFIX="10.240.111"; APPARATUS_HOST_PORT=18211
PRIMARY_PROTO_PORT=502; DOMAIN_AE_MODEL="h2_electrolyzer_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="reactor_core"; LAB_CAT_KEY="chemical"; LAB_UNIT="%"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("modbus_h2.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "PEM-Stack-PLC-01|pem-01.matrix.internal|INTEL_OPENVINO|PEM-Cell-Rectifier-01|SCADA_MODBUS_TCP|502|tcp|h2_electrolyzer_ae.onnx|ELECTRICAL|kA|4.2"
  "O2-Crossover-Sensor-02|o2-02.matrix.internal|NVIDIA_TENSORRT|H2-in-O2-Analyzer-02|CHEMICAL_PROBE|15502|tcp|h2_electrolyzer_ae.onnx|CHEMICAL|pct|0.4"
  "Gas-Separator-03|sep-03.matrix.internal|ROCKCHIP_RKNN|Anode-Pressure-03|PRESSURE_LOOP|502|tcp|squeezenet1.1-7.onnx|PRESSURE|bar|30.0"
)
LAB_ATTACK_SPEC="h2-membrane-crossover|H2_CROSSOVER|Hydrogen-in-Oxygen LEL Crossover Breach|caustic_ramp|step_increase|3.5"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
