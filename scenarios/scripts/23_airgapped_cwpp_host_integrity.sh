#!/usr/bin/env bash
SCENARIO_SLUG="23_airgapped_cwpp_host_integrity"
SCENARIO_TITLE="Air-Gapped CWPP Host & Live-SBOM Integrity Guard"
SCENARIO_DESC="Linux kernel tracepoints, TPM 2.0 PCR[10] attestation & W^X memory enforcement."
CARTRIDGE="net-guard"; SECTOR="CRITICAL_INFRA_HOST"; SUBNET_PREFIX="10.240.123"; APPARATUS_HOST_PORT=18223
PRIMARY_PROTO_PORT=443; DOMAIN_AE_MODEL="cwpp_syscall_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="goose_l2_bus"; LAB_CAT_KEY="microarch"; LAB_UNIT="err/s"
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("host_egress.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Enclave-Host-TPM-01|cwpp-01.matrix.internal|INTEL_OPENVINO|LiveSBOM-WX-Guard-01|CWPP_TRACEPOINT|443|tcp|cwpp_syscall_ae.onnx|MICROARCH|IPC|2.42"
  "Container-Runtime-02|cwpp-02.matrix.internal|NVIDIA_TENSORRT|eBPF-LSM-Audit-02|CWPP_SYSCALL|443|tcp|cwpp_syscall_ae.onnx|NETWORK|pkts|12.0"
  "TPM-Attestor-03|cwpp-03.matrix.internal|ROCKCHIP_RKNN|TPM2-PCR10-Sealer-03|PQC_MLKEM_TLS|443|tcp|resnet18-v1-7.onnx|MICROARCH|err/s|0.0"
)
LAB_ATTACK_SPEC="cwpp-wx-inject|ROWHAMMER_BITFLIP|Unsigned ELF / W^X Memory Injection|discrete_event|step_increase|18.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
