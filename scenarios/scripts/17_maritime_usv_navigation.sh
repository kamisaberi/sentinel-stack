#!/usr/bin/env bash
SCENARIO_SLUG="17_maritime_usv_navigation"
SCENARIO_TITLE="Autonomous USV Maritime Navigation Sentry"
SCENARIO_DESC="NMEA 2000 AIS transponder vs marine radar cross-modal anti-spoofing."
CARTRIDGE="ccsds-guard"; SECTOR="MARITIME_DEFENSE"; SUBNET_PREFIX="10.240.117"; APPARATUS_HOST_PORT=18217
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="usv_maritime_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="radar_360"; LAB_CAT_KEY="kinematic"; LAB_UNIT="knots"
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("nmea_ais.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "USV-Marine-Radar-01|usv-radar-01.matrix.internal|INTEL_OPENVINO|XBand-Marine-Radar-01|MARINE_RADAR|50050|udp|usv_maritime_ae.onnx|KINEMATIC|knots|24.0"
  "USV-AIS-NMEA-02|usv-ais-02.matrix.internal|NVIDIA_TENSORRT|NMEA2000-AIS-RX-02|NMEA_2000|10110|udp|usv_maritime_ae.onnx|RF_EM|dBm|-82.0"
  "USV-Rudder-Helm-03|usv-helm-03.matrix.internal|ROCKCHIP_RKNN|Rudder-Actuator-03|ACTUATOR_BUS|502|tcp|resnet18-v1-7.onnx|AVIONICS|deg|2.5"
)
LAB_ATTACK_SPEC="ais-ghost-vessel|AIS_SPOOF|Ghost Vessel AIS Collision Spoof|flatline_freeze|drop_to_val|0.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
