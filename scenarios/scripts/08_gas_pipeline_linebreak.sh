#!/usr/bin/env bash
SCENARIO_SLUG="08_gas_pipeline_linebreak"
SCENARIO_TITLE="Transcontinental Gas Pipeline Line-Break Detector"
SCENARIO_DESC="Joukowsky hydraulic water-hammer & compressor station SCADA defense."
CARTRIDGE="ics-guard"; SECTOR="MIDSTREAM_PIPELINE"; SUBNET_PREFIX="10.240.108"; APPARATUS_HOST_PORT=18208
PRIMARY_PROTO_PORT=502; DOMAIN_AE_MODEL="pipeline_pressure_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="reactor_core"; LAB_CAT_KEY="pressure"; LAB_UNIT="PSI"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("dnp3_pipe.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/dnp3/dnp3.pcap")
NODES_SPEC=(
  "Compressor-Stn-01|comp-01.matrix.internal|INTEL_OPENVINO|Turbine-Compressor-01|SCADA_MODBUS_TCP|502|tcp|pipeline_pressure_ae.onnx|PRESSURE|PSI|980.0"
  "Block-Valve-RTU-02|valve-02.matrix.internal|NVIDIA_TENSORRT|Mainline-BlockValve-02|DNP3_RTU|20000|tcp|pipeline_pressure_ae.onnx|PRESSURE|PSI|960.0"
  "Meter-Skid-03|meter-03.matrix.internal|ROCKCHIP_RKNN|Custody-Flow-Meter-03|SCADA_MODBUS_TCP|502|tcp|squeezenet1.1-7.onnx|VIBRATION|mm/s|1.9"
)
LAB_ATTACK_SPEC="pipeline-water-hammer|WATER_HAMMER|Block Valve Slam Hydraulic Shockwave|impulse_shock|step_increase|95.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
