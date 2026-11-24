#!/usr/bin/env bash
SCENARIO_SLUG="26_pqc_tls_accelerator"
SCENARIO_TITLE="Post-Quantum Cryptographic ML-KEM TLS 1.3 Accelerator"
SCENARIO_DESC="FIPS 203 ML-KEM-768/1024 TLS 1.3 handshake offload & classical downgrade guard."
CARTRIDGE="net-guard"; SECTOR="QUANTUM_CRYPTO"; SUBNET_PREFIX="10.240.126"; APPARATUS_HOST_PORT=18226
PRIMARY_PROTO_PORT=443; DOMAIN_AE_MODEL="pqc_tls_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="goose_l2_bus"; LAB_CAT_KEY="network"; LAB_UNIT="us"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("pqc_tls13.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "PQC-Edge-Proxy-01|pqc-01.matrix.internal|INTEL_OPENVINO|MLKEM768-TLS-Gate-01|PQC_MLKEM_TLS|443|tcp|pqc_tls_ae.onnx|NETWORK|us|18.5"
  "TPM-KeyVault-02|pqc-02.matrix.internal|NVIDIA_TENSORRT|TPM2-MLDSA-Signer-02|PQC_MLKEM_TLS|443|tcp|pqc_tls_ae.onnx|MICROARCH|ops|42.0"
  "SCADA-Tunnel-Peer-03|pqc-03.matrix.internal|ROCKCHIP_RKNN|OT-IPsec-Peer-03|SCADA_MODBUS_TCP|502|tcp|squeezenet1.1-7.onnx|NETWORK|ms|0.4"
)
LAB_ATTACK_SPEC="pqc-downgrade-probe|PQC_DOWNGRADE|Classical X25519 TLS Downgrade Attack|flatline_freeze|drop_to_val|0.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
