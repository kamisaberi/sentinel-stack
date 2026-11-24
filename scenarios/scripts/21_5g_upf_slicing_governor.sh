#!/usr/bin/env bash
SCENARIO_SLUG="21_5g_upf_slicing_governor"
SCENARIO_TITLE="Private 5G UPF Slicing Wire-Speed Governor"
SCENARIO_DESC="3GPP GTP-U (UDP 2152) TEID slice isolation blocking eMBB-to-URLLC slice hopping."
CARTRIDGE="net-guard"; SECTOR="TELECOM_5G"; SUBNET_PREFIX="10.240.121"; APPARATUS_HOST_PORT=18221
PRIMARY_PROTO_PORT=2152; DOMAIN_AE_MODEL="upf_gtpu_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="upf_slice_scope"; LAB_CAT_KEY="network"; LAB_UNIT="Gbps"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("free5gc_gtpu.pcap=https://raw.githubusercontent.com/NotYuSheng/TracePcap/master/free5gc.pcap")
NODES_SPEC=(
  "gNodeB-N3-Ingress-01|gnb-01.matrix.internal|INTEL_OPENVINO|N3-GTPU-Tunnel-01|5G_GTPU_SLICE|2152|udp|upf_gtpu_ae.onnx|NETWORK|Gbps|18.4"
  "UPF-Core-PFCP-02|upf-02.matrix.internal|NVIDIA_TENSORRT|N4-PFCP-Control-02|PFCP_CTRL|8805|udp|upf_gtpu_ae.onnx|NETWORK|ops|120.0"
  "URLLC-Plant-PLC-03|urllc-plc-03.matrix.internal|ROCKCHIP_RKNN|URLLC-OT-Sink-03|SCADA_MODBUS_TCP|502|tcp|squeezenet1.1-7.onnx|INDUSTRIAL_CPS|ms|0.8"
)
LAB_ATTACK_SPEC="gtpu-slice-hopping|GTPU_SLICE_HOP|eMBB TEID Hopping into URLLC OT Slice|discrete_event|step_increase|45.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
