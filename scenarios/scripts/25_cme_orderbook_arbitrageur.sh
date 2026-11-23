#!/usr/bin/env bash
SCENARIO_SLUG="25_cme_orderbook_arbitrageur"
SCENARIO_TITLE="CME MDP 3.0 SBE Wire-Speed Order Book Risk Guard"
SCENARIO_DESC="SBE binary market data feed parsing & spoofing/quote-stuffing drop engine."
CARTRIDGE="net-guard"; SECTOR="FINTECH_EXCHANGE"; SUBNET_PREFIX="10.240.125"; APPARATUS_HOST_PORT=18225
PRIMARY_PROTO_PORT=9001; DOMAIN_AE_MODEL="cme_sbe_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="itch_orderbook"; LAB_CAT_KEY="network"; LAB_UNIT="pkts/s"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("cme_mdp.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "CME-MDP3-FeedA-01|cme-a-01.matrix.internal|INTEL_OPENVINO|MDP3-Multicast-A-01|FINTECH_ITCH_50|9001|udp|cme_sbe_ae.onnx|NETWORK|pkts|4500.0"
  "SBE-OrderBook-L3-02|sbe-l3-02.matrix.internal|NVIDIA_TENSORRT|L3-Book-Builder-02|FINTECH_ITCH_50|9001|tcp|cme_sbe_ae.onnx|NETWORK|ns|88.0"
  "Clearing-Audit-03|clear-03.matrix.internal|ROCKCHIP_RKNN|DropCopy-Compliance-03|PQC_MLKEM_TLS|443|tcp|mobilenetv2-7.onnx|NETWORK|ops|95.0"
)
LAB_ATTACK_SPEC="cme-quote-stuffing|QUOTE_STUFFING|CME MDP 3.0 Microsecond Quote Stuffing|discrete_event|step_increase|95.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
