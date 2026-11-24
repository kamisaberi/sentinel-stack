#!/usr/bin/env bash
SCENARIO_SLUG="06_hvac_predictive_physics"
SCENARIO_TITLE="Commercial HVAC Predictive Physics Optimizer"
SCENARIO_DESC="BACnet/IP chiller & thermal envelope ODE optimizer against damper hijack."
CARTRIDGE="ics-guard"; SECTOR="BUILDING_AUTOMATION"; SUBNET_PREFIX="10.240.106"; APPARATUS_HOST_PORT=18206
PRIMARY_PROTO_PORT=47808; DOMAIN_AE_MODEL="hvac_bacnet_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="flir_thermal"; LAB_CAT_KEY="temperature"; LAB_UNIT="C"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("http_bms.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Chiller-Plant-01|chiller-01.matrix.internal|INTEL_OPENVINO|Chiller-Compressor-01|BACNET_IP|47808|udp|hvac_bacnet_ae.onnx|TEMPERATURE|C|7.2"
  "AHU-Damper-02|ahu-02.matrix.internal|NVIDIA_TENSORRT|Zone-Supply-AHU-02|BACNET_IP|47808|udp|hvac_bacnet_ae.onnx|PRESSURE|Pa|250.0"
  "BMS-Gateway-03|bms-03.matrix.internal|ROCKCHIP_RKNN|Thermal-Envelope-GW-03|SCADA_MODBUS_TCP|502|tcp|mobilenetv2-7.onnx|TEMPERATURE|C|21.5"
)
LAB_ATTACK_SPEC="hvac-damper-freeze|HVAC_HIJACK|BACnet Chiller Setpoint Tampering|caustic_ramp|step_increase|28.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
