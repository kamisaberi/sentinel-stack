#!/usr/bin/env bash
SCENARIO_SLUG="24_fintech_pretrade_risk_firewall"
SCENARIO_TITLE="Nanosecond FinTech ITCH / OUCH Pre-Trade Risk Firewall"
SCENARIO_DESC="SEC Rule 15c3-5 fat-finger share cap & price collar enforcement in < 15 ns."
CARTRIDGE="net-guard"; SECTOR="FINTECH_TRADING"; SUBNET_PREFIX="10.240.124"; APPARATUS_HOST_PORT=18224
PRIMARY_PROTO_PORT=9001; DOMAIN_AE_MODEL="itch_pretrade_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="itch_orderbook"; LAB_CAT_KEY="network"; LAB_UNIT="ns"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("itch_feed.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Algo-SOR-Ingress-01|sor-01.matrix.internal|INTEL_OPENVINO|NASDAQ-OUCH-Gate-01|FINTECH_ITCH_50|9001|tcp|itch_pretrade_ae.onnx|NETWORK|ns|14.2"
  "Risk-Collar-Engine-02|collar-02.matrix.internal|NVIDIA_TENSORRT|Margin-Collar-Check-02|FINTECH_ITCH_50|9001|tcp|itch_pretrade_ae.onnx|NETWORK|qty|100.0"
  "Exchange-Match-03|match-03.matrix.internal|ROCKCHIP_RKNN|Matching-Core-GW-03|PQC_MLKEM_TLS|443|tcp|squeezenet1.1-7.onnx|NETWORK|ms|0.08"
)
LAB_ATTACK_SPEC="itch-fat-finger|ITCH_FAT_FINGER|500,000-Share Algorithmic Fat-Finger Burst|impulse_shock|step_increase|90.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
