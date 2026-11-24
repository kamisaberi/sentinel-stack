#!/usr/bin/env bash
SCENARIO_SLUG="27_satcom_cloud_downlink_filter"
SCENARIO_TITLE="Satellite Onboard Hyperspectral Cloud-Cover Filter"
SCENARIO_DESC="Drops occluded cloud/ocean imagery in orbit to preserve 80% Ka-band downlink."
CARTRIDGE="net-guard"; SECTOR="AEROSPACE_CONSTELLATION"; SUBNET_PREFIX="10.240.127"; APPARATUS_HOST_PORT=18227
PRIMARY_PROTO_PORT=2152; DOMAIN_AE_MODEL="satcom_cloud_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="upf_slice_scope"; LAB_CAT_KEY="network"; LAB_UNIT="Mbps"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("satcom_downlink.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Hyperspectral-Imager-01|sat-imager-01.matrix.internal|INTEL_OPENVINO|SWIR-Cube-Capture-01|HYPERSPECTRAL|2152|udp|mobilenetv2-7.onnx|VISION|FPS|12.0"
  "Onboard-CloudGate-02|sat-filter-02.matrix.internal|NVIDIA_TENSORRT|Cloud-Mask-Inference-02|CCSDS_DOWNLINK|2152|udp|satcom_cloud_ae.onnx|NETWORK|Mbps|180.0"
  "KaBand-Transponder-03|sat-ka-03.matrix.internal|ROCKCHIP_RKNN|KaBand-Tx-Queue-03|PQC_MLKEM_TLS|443|tcp|satcom_cloud_ae.onnx|RF_EM|dBm|-62.0"
)
LAB_ATTACK_SPEC="downlink-bandwidth-flood|DOWNLINK_SATURATION|Occluded Frame Downlink Saturation|caustic_ramp|step_increase|75.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
