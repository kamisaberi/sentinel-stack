#!/usr/bin/env bash
SCENARIO_SLUG="02_synchrophasor_grid_stability"
SCENARIO_TITLE="Synchrophasor Grid Stability Guard"
SCENARIO_DESC="IEEE C37.118.2 PMU frequency, ROCOF & harmonic stability governor."
CARTRIDGE="ics-guard"; SECTOR="POWER_UTILITIES"; SUBNET_PREFIX="10.240.102"; APPARATUS_HOST_PORT=18202
PRIMARY_PROTO_PORT=15501; DOMAIN_AE_MODEL="pmu_stability_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="synchrophasor"; LAB_CAT_KEY="electrical"; LAB_UNIT="Hz"; LAB_MIN=48.0; LAB_MAX=52.0; LAB_SAFE_LOW=49.5; LAB_SAFE_HIGH=50.5
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("dnp3_scada.pcap=https://raw.githubusercontent.com/ITI/ICS-Security-Tools/master/pcaps/bro/dnp3/dnp3.pcap")
NODES_SPEC=(
  "PMU-Pylon-North|pmu-north.matrix.internal|INTEL_OPENVINO|PMU-Phasor-01|IEEE_C37118_PMU|15501|tcp|pmu_stability_ae.onnx|ELECTRICAL|Hz|50.01"
  "PDC-Concentrator-02|pdc-02.matrix.internal|NVIDIA_TENSORRT|PDC-Aggregator-02|DNP3_SUBSTATION|20000|tcp|pmu_stability_ae.onnx|ELECTRICAL|deg|0.4"
  "SVC-Compensator-03|svc-03.matrix.internal|ROCKCHIP_RKNN|Harmonic-Filter-PLC-03|SCADA_MODBUS_TCP|502|tcp|squeezenet1.1-7.onnx|INDUSTRIAL_CPS|THD|1.4"
)
LAB_ATTACK_SPEC="pmu-rocof-cascade|ROCOF_BLACKOUT|ROCOF Underfrequency Blackout Trip|harmonic_sideband|harmonic_multiplier|2.8"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
