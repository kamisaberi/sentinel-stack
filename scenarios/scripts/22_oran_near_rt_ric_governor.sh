#!/usr/bin/env bash
SCENARIO_SLUG="22_oran_near_rt_ric_governor"
SCENARIO_TITLE="O-RAN Near-RT RIC Security Governor"
SCENARIO_DESC="O-RAN E2AP SCTP (:36422) rogue xApp isolation via Wasm3 micro-sandboxing."
CARTRIDGE="net-guard"; SECTOR="TELECOM_ORAN"; SUBNET_PREFIX="10.240.122"; APPARATUS_HOST_PORT=18222
PRIMARY_PROTO_PORT=36422; DOMAIN_AE_MODEL="oran_e2ap_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="upf_slice_scope"; LAB_CAT_KEY="network"; LAB_UNIT="us"
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("oran_ecpri.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "ORAN-ODU-Cell-01|odu-01.matrix.internal|INTEL_OPENVINO|E2AP-SCTP-Node-01|ORAN_E2_SCTP|36422|sctp|oran_e2ap_ae.onnx|NETWORK|us|0.62"
  "NearRT-RIC-xApp-02|ric-02.matrix.internal|NVIDIA_TENSORRT|Wasm3-xApp-Host-02|ORAN_XAPP|36422|sctp|oran_e2ap_ae.onnx|NETWORK|ops|85.0"
  "OCU-Backhaul-03|ocu-03.matrix.internal|ROCKCHIP_RKNN|OCU-F1U-Tunnel-03|5G_GTPU_SLICE|2152|udp|mobilenetv2-7.onnx|NETWORK|Gbps|9.4"
)
LAB_ATTACK_SPEC="oran-rogue-xapp|ORAN_ROGUE_XAPP|Rogue xApp E2 RICcontrol Beam Hijack|harmonic_sideband|harmonic_multiplier|2.5"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
