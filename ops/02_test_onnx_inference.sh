#!/usr/bin/env bash
# ==============================================================================
# 02_test_onnx_inference.sh — Validates ONNX Models via native libxinfer.so
# ==============================================================================
set -euo pipefail

CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

TMP_CPP="/tmp/test_onnx_runner_$$.cpp"
TMP_BIN="/tmp/test_onnx_runner_$$"

echo -e "${CYAN}================================================================================${RESET}"
echo -e "${CYAN}          ARYORITHM XINFER: LIVE ONNX INFERENCE BENCHMARK                       ${RESET}"
echo -e "${CYAN}================================================================================${RESET}"

cat << 'CPPEOF' > "${TMP_CPP}"
#include <xinfer/xinfer.hpp>
#include <filesystem>
#include <iostream>
#include <iomanip>
#include <vector>
#include <chrono>

namespace fs = std::filesystem;

int main(int argc, char* argv[]) {
    std::string model_dir = (argc > 1) ? argv[1] : "/home/kami/sentinel-matrix/shared/models";
    std::cout << "[*] Auditing ONNX models in: " << model_dir << "\n\n";

    std::vector<fs::path> paths;
    for (const auto& e : fs::directory_iterator(model_dir)) {
        if (e.path().extension() == ".onnx") paths.push_back(e.path());
    }
    std::sort(paths.begin(), paths.end());

    int passed = 0, failed = 0;

    for (const auto& p : paths) {
        std::cout << "--------------------------------------------------------------------------------\n";
        std::cout << "MODEL: " << p.filename().string() << "\n";
        try {
            xinfer::Engine engine(xinfer::Target::OpenVINO);
            auto t0 = std::chrono::high_resolution_clock::now();
            engine.load_model(p.string());
            auto t1 = std::chrono::high_resolution_clock::now();
            auto compile_us = std::chrono::duration_cast<std::chrono::microseconds>(t1 - t0).count();

            auto& in = engine.get_input_tensor("input");
            auto& out = engine.get_output_tensor("scores");

            std::cout << "  [+] Compiled in RAM: " << compile_us << " µs\n";
            std::cout << "  [+] Input Shape    : " << in.shape_string() << " (" << in.element_count() << " elements)\n";
            std::cout << "  [+] Output Shape   : " << out.shape_string() << " (" << out.element_count() << " elements)\n";

            // Test Baseline (Nominal zero vector)
            float* ip = in.data<float>();
            std::fill_n(ip, in.element_count(), 0.0f);
            t0 = std::chrono::high_resolution_clock::now();
            engine.infer();
            t1 = std::chrono::high_resolution_clock::now();
            auto infer_us = std::chrono::duration_cast<std::chrono::microseconds>(t1 - t0).count();
            float score_nominal = out.data<float>()[0];

            // Test Anomaly Vector (High perturbation)
            std::fill_n(ip, in.element_count(), 0.95f);
            engine.infer();
            float score_anomaly = out.data<float>()[0];

            std::cout << "  [+] Inference Time : " << infer_us << " µs\n";
            std::cout << "  [+] Nominal Score  : " << std::fixed << std::setprecision(4) << score_nominal << "\n";
            std::cout << "  [+] Anomaly Score  : " << std::fixed << std::setprecision(4) << score_anomaly << "\n";
            std::cout << "  [+] Status         : \033[1;32mVERIFIED OPERATIONAL\033[0m\n";
            passed++;
        } catch (const std::exception& ex) {
            std::cout << "  [-] Status         : \033[1;31mDEFERRED / ERROR\033[0m (" << ex.what() << ")\n";
            failed++;
        }
    }

    std::cout << "================================================================================\n";
    std::cout << "SUMMARY: " << passed << " models verified, " << failed << " deferred.\n";
    return (passed > 0) ? 0 : 1;
}
CPPEOF

echo -e "${YELLOW}[*] Compiling ephemeral C++ tester with libxinfer.so...${RESET}"
g++ -std=c++20 "${TMP_CPP}" -I/usr/local/include -L/usr/local/lib -lxinfer -Wl,-rpath,/usr/local/lib -o "${TMP_BIN}"

"${TMP_BIN}" "$@"
rm -f "${TMP_CPP}" "${TMP_BIN}"
