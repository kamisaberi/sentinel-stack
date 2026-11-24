#!/usr/bin/env bash
SCENARIO_SLUG="28_cobot_iso13849_governor"
SCENARIO_TITLE="Collaborative Robot ISO 13849 PL-e Safety Governor"
SCENARIO_DESC="Non-IP EtherCAT (0x88A4) joint acceleration & Nagumo CBF workspace clamp."
CARTRIDGE="motion-guard"; SECTOR="ROBOTICS_COBOT"; SUBNET_PREFIX="10.240.128"; APPARATUS_HOST_PORT=18228
PRIMARY_PROTO_PORT=502; PRIMARY_ETHERTYPE="0x88A4"; DOMAIN_AE_MODEL="cobot_ethercat_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="cobot_ethercat_scope"; LAB_CAT_KEY="kinematic"; LAB_UNIT="m/s"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("ethercat_cobot.pcap=https://raw.githubusercontent.com/automayt/ICS-pcap/master/S7/4-S7comm-Download-DB1-with-password-request/4-S7comm-Download-DB1-with-password-request.pcap")
NODES_SPEC=(
  "Cobot-EtherCAT-Master-01|cobot-ecat-01.matrix.internal|INTEL_OPENVINO|6Axis-Servo-Bus-01|ETHERCAT_L2_SERVO|0|l2_raw|cobot_ethercat_ae.onnx|KINEMATIC|m/s|1.2"
  "Force-Torque-Wrist-02|cobot-ft-02.matrix.internal|NVIDIA_TENSORRT|ISO15066-ForceLim-02|MOTION_CBF|0|l2_raw|cobot_ethercat_ae.onnx|KINEMATIC|Nm|18.0"
  "Safety-PLC-STO-03|cobot-sto-03.matrix.internal|ROCKCHIP_RKNN|SafeTorqueOff-Relay-03|SCADA_MODBUS_TCP|502|tcp|squeezenet1.1-7.onnx|INDUSTRIAL_CPS|ms|0.4"
)
LAB_ATTACK_SPEC="cobot-joint-surge|COBOT_CRUSH|48 m/s2 Collaborative Arm Joint Surge|impulse_shock|step_increase|45.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
