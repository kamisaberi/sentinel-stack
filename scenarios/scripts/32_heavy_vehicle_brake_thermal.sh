#!/usr/bin/env bash
SCENARIO_SLUG="32_heavy_vehicle_brake_thermal"
SCENARIO_TITLE="Commercial Heavy Vehicle Brake Thermal Fade Monitor"
SCENARIO_DESC="Wheel-hub IR thermal ODE predicting mountain-decline brake fade via CAN-FD."
CARTRIDGE="motion-guard"; SECTOR="COMMERCIAL_FLEET"; SUBNET_PREFIX="10.240.132"; APPARATUS_HOST_PORT=18232
PRIMARY_PROTO_PORT=513; DOMAIN_AE_MODEL="brake_thermal_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="amr_shm_lidar"; LAB_CAT_KEY="temperature"; LAB_UNIT="C"; LAB_MIN=20.0; LAB_MAX=450.0; LAB_SAFE_LOW=25.0; LAB_SAFE_HIGH=320.0
ONNX_SOURCES=("mobilenetv2-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx")
PCAP_SOURCES=("fleet_j1939.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Axle-IR-Therm-01|axle-ir-01.matrix.internal|ROCKCHIP_RKNN|WheelHub-IR-Probe-01|SHM_RING_MOTION|1|shm_ring|brake_thermal_ae.onnx|TEMPERATURE|C|115.0"
  "J1939-Retarder-02|retarder-02.matrix.internal|INTEL_OPENVINO|Engine-Retarder-CAN-02|SOCKETCAN_CANFD|513|can|brake_thermal_ae.onnx|KINEMATIC|Nm|1200.0"
  "Trailer-ABS-ECU-03|abs-03.matrix.internal|NVIDIA_TENSORRT|Trailer-EBS-Valves-03|SOCKETCAN_CANFD|514|can|mobilenetv2-7.onnx|PRESSURE|bar|7.2"
)
LAB_ATTACK_SPEC="brake-thermal-fade|BRAKE_OVERHEAT|Mountain Descent Brake Disc Runaway (>320C)|caustic_ramp|step_increase|240.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
