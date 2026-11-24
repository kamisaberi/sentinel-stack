#!/usr/bin/env bash
SCENARIO_SLUG="10_metallurgy_casting_breakout"
SCENARIO_TITLE="Continuous Metallurgy Casting Breakout Inspector"
SCENARIO_DESC="Molten steel caster mold thermal phase-plane & strand oscillation guard."
CARTRIDGE="ics-guard"; SECTOR="METALLURGY"; SUBNET_PREFIX="10.240.110"; APPARATUS_HOST_PORT=18210
PRIMARY_PROTO_PORT=502; DOMAIN_AE_MODEL="caster_mold_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="flir_thermal"; LAB_CAT_KEY="metallurgy"; LAB_UNIT="C"; LAB_MIN=600.0; LAB_MAX=1600.0; LAB_SAFE_LOW=900.0; LAB_SAFE_HIGH=1350.0
ONNX_SOURCES=("resnet18-v1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/resnet/model/resnet18-v1-7.onnx")
PCAP_SOURCES=("modbus_caster.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/modbus/modbus.pcap")
NODES_SPEC=(
  "Mold-Thermocouple-01|mold-01.matrix.internal|INTEL_OPENVINO|Copper-Mold-Array-01|THERMOCOUPLE_BUS|502|tcp|caster_mold_ae.onnx|METALLURGY|C|1180.0"
  "Strand-Oscillator-02|strand-02.matrix.internal|NVIDIA_TENSORRT|Hydraulic-Oscillator-02|VIBRATION_PROBE|15502|tcp|caster_mold_ae.onnx|VIBRATION|mm/s|3.1"
  "Tundish-FLIR-03|tundish-03.matrix.internal|ROCKCHIP_RKNN|Tundish-Pyrometer-03|FLIR_RTSP_STREAM|8554|tcp|resnet18-v1-7.onnx|TEMPERATURE|C|1520.0"
)
LAB_ATTACK_SPEC="casting-breakout-surge|CASTING_BREAKOUT|Molten Caster Mold Rupture Surge|caustic_ramp|step_increase|90.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
