#!/usr/bin/env bash
SCENARIO_SLUG="04_nuclear_control_rod_verifier"
SCENARIO_TITLE="Nuclear Control Rod Hydraulic Safety Verifier"
SCENARIO_DESC="Lyapunov stability & Nagumo CBF verification of reactor control rod actuation."
CARTRIDGE="ics-guard"; SECTOR="NUCLEAR_ENERGY"; SUBNET_PREFIX="10.240.104"; APPARATUS_HOST_PORT=18204
PRIMARY_PROTO_PORT=102; DOMAIN_AE_MODEL="nuclear_rod_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="reactor_core"; LAB_CAT_KEY="nuclear"; LAB_UNIT="C"; LAB_MIN=250.0; LAB_MAX=450.0; LAB_SAFE_LOW=280.0; LAB_SAFE_HIGH=350.0
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("triton_sis.pcap=https://raw.githubusercontent.com/NozomiNetworks/tricotools/master/malware_exec.pcap")
NODES_SPEC=(
  "Reactor-CRDM-01|crdm-01.matrix.internal|INTEL_OPENVINO|Control-Rod-Drive-01|SCADA_S7COMM_MODBUS|102|tcp|nuclear_rod_ae.onnx|NUCLEAR|mm|1200.0"
  "Core-Cladding-SIS-02|sis-02.matrix.internal|NVIDIA_TENSORRT|Cladding-Temp-SIS-02|TRISTATION_SIS|502|tcp|nuclear_rod_ae.onnx|TEMPERATURE|C|312.0"
  "Primary-Coolant-03|coolant-03.matrix.internal|ROCKCHIP_RKNN|Primary-Loop-Flow-03|PRESSURE_LOOP|15502|tcp|resnet18-v1-7.onnx|PRESSURE|bar|155.0"
)
LAB_ATTACK_SPEC="nuclear-dnb-trip|NUCLEAR_DNB|Stuck Control Rod Departure from Nucleate Boiling|caustic_ramp|step_increase|75.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
