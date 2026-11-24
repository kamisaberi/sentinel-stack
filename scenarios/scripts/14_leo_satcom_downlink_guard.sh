#!/usr/bin/env bash
SCENARIO_SLUG="14_leo_satcom_downlink_guard"
SCENARIO_TITLE="LEO Satellite Telecommand & Downlink Guard"
SCENARIO_DESC="CCSDS 133.0-B-2 Space Packet & AOCS thruster telecommand firewall."
CARTRIDGE="ccsds-guard"; SECTOR="AEROSPACE_SATCOM"; SUBNET_PREFIX="10.240.114"; APPARATUS_HOST_PORT=18214
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="satcom_ccsds_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="radar_360"; LAB_CAT_KEY="aerospace_ccsds"; LAB_UNIT="ns"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("satcom_link.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "GS-KaBand-Modem-01|gs-modem-01.matrix.internal|INTEL_OPENVINO|CCSDS-Uplink-Gate-01|CCSDS_TC_FRAME|50050|udp|satcom_ccsds_ae.onnx|AEROSPACE_CCSDS|ns|24.0"
  "LEO-AOCS-Bus-02|leo-aocs-02.matrix.internal|NVIDIA_TENSORRT|Star-Tracker-IMU-02|SPACE_AVIONICS|50051|udp|satcom_ccsds_ae.onnx|KINEMATIC|deg/s|0.5"
  "Payload-SBand-03|leo-sband-03.matrix.internal|ROCKCHIP_RKNN|Downlink-Crypto-03|CCSDS_SEC|50052|udp|mobilenetv2-7.onnx|RF_EM|dBm|-91.0"
)
LAB_ATTACK_SPEC="ccsds-spi-tamper|CCSDS_TAMPER|Unauthorized AOCS Thruster SPI Tamper|impulse_shock|step_increase|55.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
