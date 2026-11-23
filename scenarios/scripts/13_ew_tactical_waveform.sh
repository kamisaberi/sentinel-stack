#!/usr/bin/env bash
SCENARIO_SLUG="13_ew_tactical_waveform"
SCENARIO_TITLE="Electronic Warfare Tactical Waveform Classifier"
SCENARIO_DESC="Sub-20 us I/Q baseband RF waveform & spoofing beacon classifier."
CARTRIDGE="ccsds-guard"; SECTOR="ELECTRONIC_WARFARE"; SUBNET_PREFIX="10.240.113"; APPARATUS_HOST_PORT=18213
PRIMARY_PROTO_PORT=50050; DOMAIN_AE_MODEL="ew_iq_waveform_ae.onnx"; DOMAIN_AE_DIM=64
APPARATUS_TYPE="radar_360"; LAB_CAT_KEY="rf_em"; LAB_UNIT="dBm"
ONNX_SOURCES=("squeezenet1.1-7.onnx=https://github.com/onnx/models/raw/main/validated/vision/classification/squeezenet/model/squeezenet1.1-7.onnx")
PCAP_SOURCES=("ew_baseline.pcap=https://raw.githubusercontent.com/wireshark/wireshark/master/test/captures/http.pcap")
NODES_SPEC=(
  "EW-IQ-FrontEnd-01|ew-iq-01.matrix.internal|INTEL_OPENVINO|VITA49-IQ-Stream-01|TACTICAL_RADIO_SDR|50050|udp|ew_iq_waveform_ae.onnx|RF_EM|dBm|-84.0"
  "EW-DF-Array-02|ew-df-02.matrix.internal|NVIDIA_TENSORRT|Direction-Finder-02|RF_SPECTRUM|50051|udp|ew_iq_waveform_ae.onnx|RF_EM|deg|62.0"
  "EW-ECM-Pod-03|ew-ecm-03.matrix.internal|ROCKCHIP_RKNN|ECM-Waveform-Gen-03|STANAG_4586|50050|udp|squeezenet1.1-7.onnx|AVIONICS|ms|1.2"
)
LAB_ATTACK_SPEC="ew-drfm-deception|GNSS_SPOOF|DRFM Range-Gate Pull-Off Jamming|coherence_decay|step_increase|35.0"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/scenario_provision_lib.sh"
provision_and_stage_scenario "$@"
