#!/usr/bin/env bash
SCENARIO_SLUG="01_substation_busbar_trip"
SCENARIO_TITLE="High-Voltage Substation Busbar Trip Engine"
SCENARIO_DESC="IEC 61850 / IEC-104 110kV-330kV busbar differential protection & trip guard."
CARTRIDGE="ics-guard"; SECTOR="ENERGY_GRID"; SUBNET_PREFIX="10.240.101"; APPARATUS_HOST_PORT=18201
PRIMARY_PROTO_PORT=2404; PRIMARY_ETHERTYPE="0x0800"; DOMAIN_AE_MODEL="busbar_trip_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="synchrophasor"; LAB_CAT_KEY="electrical"; LAB_UNIT="kV"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("iec104_grid.pcap=https://raw.githubusercontent.com/automayt/ICS-pcap/master/IEC%2060870/iec104/iec104.pcap")
NODES_SPEC=(
  "HV-Relay-Bay01|hv-relay-01.matrix.internal|INTEL_OPENVINO|Busbar-Diff-Relay-01|IEC104_BREAKER|2404|tcp|busbar_trip_ae.onnx|ELECTRICAL|kV|220.4"
  "Merging-Unit-02|mu-02.matrix.internal|NVIDIA_TENSORRT|Busbar-CT-PT-MU-02|GRID_PAC3200_METER|15501|tcp|busbar_trip_ae.onnx|ELECTRICAL|Hz|50.0"
  "Substation-RTU-03|rtu-03.matrix.internal|ROCKCHIP_RKNN|Breaker-Interlock-RTU-03|SCADA_MODBUS_TCP|502|tcp|mobilenetv2-7.onnx|INDUSTRIAL_CPS|ops|12.0"
)
LAB_ATTACK_SPEC="busbar-spurious-trip|IEC104_TRIP|Spurious Busbar Breaker Trip (COT=6)|impulse_shock|step_decrease|2.1"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
