#!/usr/bin/env bash
SCENARIO_SLUG="09_smart_factory_profinet_guard"
SCENARIO_TITLE="Smart Factory Profinet & OPC-UA Cell Monitor"
SCENARIO_DESC="Siemens S7/Profinet assembly cell inspection with vibration anomaly autoencoder."
CARTRIDGE="ics-guard"; SECTOR="SMART_MANUFACTURING"; SUBNET_PREFIX="10.240.109"; APPARATUS_HOST_PORT=18209
PRIMARY_PROTO_PORT=102; DOMAIN_AE_MODEL="factory_s7_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="reactor_core"; LAB_CAT_KEY="vibration"; LAB_UNIT="mm/s"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("s7_factory.pcap=https://raw.githubusercontent.com/automayt/ICS-pcap/master/S7/4-S7comm-Download-DB1-with-password-request/4-S7comm-Download-DB1-with-password-request.pcap")
NODES_SPEC=(
  "Assembly-S7-1500-01|s7-01.matrix.internal|INTEL_OPENVINO|Welding-Cell-PLC-01|SCADA_S7COMM_MODBUS|102|tcp|factory_s7_ae.onnx|INDUSTRIAL_CPS|ops|25.0"
  "Spindle-Vib-02|vib-02.matrix.internal|NVIDIA_TENSORRT|CNC-Bearing-Probe-02|VIBRATION_PROBE|15502|tcp|factory_s7_ae.onnx|VIBRATION|mm/s|1.4"
  "OPCUA-MES-GW-03|opcua-03.matrix.internal|ROCKCHIP_RKNN|OPCUA-Historian-GW-03|OPCUA_TCP|4840|tcp|mobilenetv2-7.onnx|NETWORK|pkts|40.0"
)
LAB_ATTACK_SPEC="s7-cell-stop|S7_STOP|Unauthorized S7-1500 CPU STOP Injection|discrete_event|step_increase|55.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
