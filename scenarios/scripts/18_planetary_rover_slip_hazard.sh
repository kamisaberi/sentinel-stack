#!/usr/bin/env bash
SCENARIO_SLUG="18_planetary_rover_slip_hazard"
SCENARIO_TITLE="Planetary Lunar / Martian Rover Slip & Rollover Guard"
SCENARIO_DESC="Burckhardt granular-soil wheel slip RK4 ODE & tipping-angle Nagumo CBF."
CARTRIDGE="ccsds-guard"; SECTOR="SPACE_EXPLORATION"; SUBNET_PREFIX="10.240.118"; APPARATUS_HOST_PORT=18218
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="rover_slip_ae.onnx"; DOMAIN_AE_DIM=32
APPARATUS_TYPE="formation_hud"; LAB_CAT_KEY="kinematic"; LAB_UNIT="deg"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("rover_nav.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "Rover-NavCam-01|rover-cam-01.matrix.internal|INTEL_OPENVINO|Stereo-NavCam-01|STEREO_VISION|8554|tcp|squeezenet1.1-7.onnx|VISION|FPS|15.0"
  "Rover-IMU-Slope-02|rover-imu-02.matrix.internal|NVIDIA_TENSORRT|Attitude-IMU-02|KINEMATIC_IMU|50050|udp|rover_slip_ae.onnx|KINEMATIC|deg|5.0"
  "RockerBogie-Drive-03|rover-drv-03.matrix.internal|ROCKCHIP_RKNN|6Wheel-Slip-Ctrl-03|CCSDS_TC_FRAME|50051|udp|rover_slip_ae.onnx|AVIONICS|m/s|0.25"
)
LAB_ATTACK_SPEC="rover-regolith-tip|ROVER_TIPPING|Regolith Sinkage & Slope Rollover Breach|caustic_ramp|step_increase|28.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
