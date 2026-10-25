#pragma once

#include "common.hpp"
#include "help_manuals.hpp"

inline int dispatch_domain(const std::string &domain, const std::vector<std::string> &args)
{
    bool wants_help = (!args.empty() && is_help_flag(args[0]));

    // -------------------------------------------------------------------------
    // [01. Authentication & Identity]
    // -------------------------------------------------------------------------
    if (domain == "login" || domain == "whoami")
    {
        std::vector<std::string> ctl_args = {domain};
        ctl_args.insert(ctl_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", ctl_args);
    }
    if (domain == "auth")
    {
        std::vector<std::string> nexus_args = {"auth"};
        nexus_args.insert(nexus_args.end(), args.begin(), args.end());
        forward_exec("nexus-ctl", nexus_args);
    }

    // -------------------------------------------------------------------------
    // [02. Appliance, Routing & Hardware]
    // -------------------------------------------------------------------------
    if (domain == "status")
    {
        forward_exec("sentinel-ctl", {"status"});
    }
    if (domain == "appliance")
    {
        if (args.empty() || wants_help)
        {
            print_help_appliance();
            return 0;
        }
        forward_exec("sentinel-ctl", args);
    }
    if (domain == "license" || domain == "hardware")
    {
        if (wants_help)
        {
            print_help_appliance();
            return 0;
        }
        std::vector<std::string> hw_args = {domain};
        hw_args.insert(hw_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", hw_args);
    }

    // -------------------------------------------------------------------------
    // [03. Stack & Services]
    // -------------------------------------------------------------------------
    if (domain == "stack")
    {
        if (args.empty() || wants_help)
        {
            print_help_stack();
            return 0;
        }
        std::string sub = args[0];
        if (sub == "install")
            return run_shell("sudo /home/kami/sentinel-stack/install.sh");
        if (sub == "build")
            return run_shell("/home/kami/sentinel-stack/build_all.sh");
        if (sub == "verify")
            return run_shell("/home/kami/sentinel-stack/verify_stack.sh");
        if (sub == "uninstall")
            return run_shell("sudo /home/kami/sentinel-stack/uninstall.sh");
        if (sub == "purge")
            return run_shell("sudo /home/kami/sentinel-stack/uninstall.sh --yes");
        if (sub == "env")
        {
            std::cout << "\033[1;36m[*] Auditing Sentinel-Stack Environment:\033[0m\n";
            std::cout << "  • Kernel Version   : " << run_shell("uname -r") << "\n";
            std::cout << "  • Python Virtualenv: " << (fs::exists("/opt/sentinel-stack/venv") ? "\033[1;32mINSTALLED\033[0m" : "\033[1;31mMISSING\033[0m") << "\n";
            std::cout << "  • Central Cache    : " << (fs::exists("/var/cache/sentinel") ? "\033[1;32mONLINE\033[0m" : "\033[1;31mMISSING\033[0m") << "\n";
            return 0;
        }
    }

    if (domain == "service")
    {
        if (args.empty() || wants_help)
        {
            print_help_stack();
            return 0;
        }
        std::string action = args[0];
        std::string target = (args.size() > 1) ? args[1] : "all";

        std::vector<std::string> svcs;
        if (target == "sentinel")
            svcs.push_back("blackbox-sentinel");
        else if (target == "nexus")
            svcs.push_back("sentinel-nexus");
        else
        {
            svcs.push_back("blackbox-sentinel");
            svcs.push_back("sentinel-nexus");
        }

        if (action == "logs")
        {
            std::string svc_name = (target == "nexus") ? "sentinel-nexus" : "blackbox-sentinel";
            std::string follow = (args.size() > 2 && args[2] == "-f") ? " -f" : "";
            return run_shell("journalctl -u " + svc_name + follow);
        }

        for (const auto &s : svcs)
        {
            std::string sys_cmd = "sudo systemctl " + action + " " + s;
            if (action == "status")
                sys_cmd = "systemctl status " + s;
            run_shell(sys_cmd);
        }
        return 0;
    }

    // -------------------------------------------------------------------------
    // [04. Global Hub Discovery & Publishing]
    // -------------------------------------------------------------------------
    if (domain == "hub")
    {
        if (wants_help)
        {
            print_help_hub();
            return 0;
        }

        std::vector<std::string> hub_args = {"hub"};
        hub_args.insert(hub_args.end(), args.begin(), args.end());

        if (!args.empty() && (args[0] == "broadcast" || args[0] == "new"))
        {
            forward_exec("nexus-ctl", hub_args);
        }
        else
        {
            forward_exec("sentinel-ctl", hub_args);
        }
    }

    if (domain == "publish")
    {
        std::vector<std::string> pub_args = {"publish"};
        pub_args.insert(pub_args.end(), args.begin(), args.end());
        forward_exec("sentinel-artifact", pub_args);
    }

    // -------------------------------------------------------------------------
    // [05. Symmetrical Asset Lifecycles (package, model, dataset, pcap, scenario)]
    // -------------------------------------------------------------------------
    if (domain == "package" || domain == "artifact")
    {
        if (wants_help)
        {
            print_help_package();
            return 0;
        }
        if (!args.empty() && (args[0] == "pack" || args[0] == "new" || args[0] == "inspect" ||
                              args[0] == "verify" || args[0] == "test" || args[0] == "keygen" ||
                              args[0] == "extract-source" || args[0] == "synthesize-vaccine"))
        {
            forward_exec("sentinel-artifact", args);
        }
        else
        {
            std::vector<std::string> p_args = {"package"};
            p_args.insert(p_args.end(), args.begin(), args.end());
            forward_exec("sentinel-ctl", p_args);
        }
    }

    if (domain == "model")
    {
        if (wants_help)
        {
            print_help_model();
            return 0;
        }
        std::vector<std::string> d_args = {"model"};
        d_args.insert(d_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", d_args);
    }

    if (domain == "dataset")
    {
        if (wants_help)
        {
            print_help_dataset();
            return 0;
        }
        std::vector<std::string> d_args = {"dataset"};
        d_args.insert(d_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", d_args);
    }

    if (domain == "pcap")
    {
        if (wants_help)
        {
            print_help_pcap();
            return 0;
        }
        std::vector<std::string> p_args = {"pcap"};
        p_args.insert(p_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", p_args);
    }

    if (domain == "scenario")
    {
        if (wants_help)
        {
            print_help_scenario();
            return 0;
        }
        std::vector<std::string> sc_args = {"scenario"};
        sc_args.insert(sc_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", sc_args);
    }

    // -------------------------------------------------------------------------
    // [07. Fleet & Threat Administration]
    // -------------------------------------------------------------------------
    if (domain == "fleet" || domain == "threat" || domain == "ota" || domain == "report")
    {
        if (wants_help)
        {
            print_help_fleet();
            return 0;
        }
        std::vector<std::string> n_args = {domain};
        n_args.insert(n_args.end(), args.begin(), args.end());
        forward_exec("nexus-ctl", n_args);
    }

    // -------------------------------------------------------------------------
    // [08. Continual AI & Quantization (Forge)]
    // -------------------------------------------------------------------------
    if (domain == "forge")
    {
        if (wants_help)
        {
            print_help_forge();
            return 0;
        }
        forward_exec("forge-cli", args);
    }

    // -------------------------------------------------------------------------
    // [09. SLAB Protocol Engine]
    // -------------------------------------------------------------------------
    if (domain == "slab")
    {
        if (!args.empty() && args[0] == "stream")
        {
            std::vector<std::string> s_args = {"slab"};
            s_args.insert(s_args.end(), args.begin(), args.end());
            forward_exec("sentinel-ctl", s_args);
        }
        else
        {
            std::vector<std::string> s_args = {"slab"};
            s_args.insert(s_args.end(), args.begin(), args.end());
            forward_exec("sentinel-artifact", s_args);
        }
    }

    // -------------------------------------------------------------------------
    // [10. Research Lab (14 Scientific Modules)]
    // -------------------------------------------------------------------------
    if (domain == "lab")
    {
        if (args.empty() || wants_help)
        {
            print_help_lab();
            return 0;
        }
        std::string act = args[0];
        std::string venv_py = "/opt/sentinel-stack/venv/bin/python3";
        std::string h_dir = "/opt/sentinel-stack/harnesses";

        std::string flag_str = "";
        for (size_t i = 1; i < args.size(); ++i)
            flag_str += " " + args[i];

        if (act == "daemon")
        {
            std::vector<std::string> lab_args(args.begin() + 1, args.end());
            forward_exec("sentinel_lab", lab_args);
        }
        else if (act == "inspect-matrix")
            return run_shell(venv_py + " " + h_dir + "/matrix_live_tap.py" + flag_str);
        else if (act == "blast")
            return run_shell(venv_py + " " + h_dir + "/socket_injector.py" + flag_str);
        else if (act == "evasion")
            return run_shell(venv_py + " " + h_dir + "/socket_injector.py --evasion-mode" + flag_str);
        else if (act == "drift")
            return run_shell(venv_py + " " + h_dir + "/drift_evaluator.py" + flag_str);
        else if (act == "hil")
            return run_shell(venv_py + " " + h_dir + "/hil_co_simulator.py" + flag_str);
        else if (act == "fuzzer")
            return run_shell(venv_py + " " + h_dir + "/scada_fuzzer.py" + flag_str);
        else if (act == "fdia")
            return run_shell(venv_py + " " + h_dir + "/fdia_orchestrator.py" + flag_str);
        else if (act == "quant")
            return run_shell(venv_py + " " + h_dir + "/quant_evaluator.py" + flag_str);
        else if (act == "pqc")
            return run_shell(venv_py + " " + h_dir + "/pqc_tunnel_profiler.py" + flag_str);
        else if (act == "stateful")
            return run_shell(venv_py + " " + h_dir + "/stateful_fuzzer.py" + flag_str);
        else if (act == "sidechannel")
            return run_shell(venv_py + " " + h_dir + "/sidechannel_analyzer.py" + flag_str);
        else if (act == "cbf")
            return run_shell(venv_py + " " + h_dir + "/cbf_reachability_evaluator.py" + flag_str);
        else if (act == "federated")
            return run_shell(venv_py + " " + h_dir + "/federated_poison_evaluator.py" + flag_str);
        else if (act == "patch-regression")
            return run_shell(venv_py + " " + h_dir + "/patch_regression_evaluator.py" + flag_str);
        else
        {
            std::cerr << "[-] Error: Unknown lab action '" << act << "'. Run 'aryo lab --help'.\n";
            return 1;
        }
    }

    // -------------------------------------------------------------------------
    // [11. Digital Twin Range Mesh & Active Honeynet]
    // -------------------------------------------------------------------------
    if (domain == "matrix")
    {
        if (args.empty() || wants_help)
        {
            print_help_matrix();
            return 0;
        }
        std::string act = args[0];

        if (act == "plc")
        {
            std::vector<std::string> plc_args(args.begin() + 1, args.end());
            forward_exec("mock_plc", plc_args);
        }
        else if (act == "honeynet-autohunt")
        {
            std::string spool = (args.size() > 1) ? args[1] : "/var/run/sentinel/honeynet_spool";
            std::string synth_cmd = "sentinel-artifact synthesize-vaccine " + spool + " /tmp/honeynet_vaccines";
            int ret = run_shell(synth_cmd);
            if (ret != 0)
                return 1;

            std::string bcast_cmd = "for f in /tmp/honeynet_vaccines/*/*.spkg; do "
                                    "  if [ -f \"$f\" ]; then "
                                    "    nexus-ctl hub broadcast \"$f\"; break; "
                                    "  fi; "
                                    "done";
            return run_shell(bcast_cmd);
        }
        else if (act == "scenario" && args.size() > 1)
        {
            std::string sub_act = args[1];
            std::string extra_args = "";
            for (size_t i = 2; i < args.size(); ++i)
                extra_args += " " + args[i];

            if (sub_act == "load")
                return run_shell("python3 /home/kami/sentinel-matrix/tools/scenario_engine.py load" + extra_args);
            if (sub_act == "down")
                return run_shell("python3 /home/kami/sentinel-matrix/tools/scenario_engine.py down" + extra_args);
            if (sub_act == "status")
                return run_shell("python3 /home/kami/sentinel-matrix/tools/scenario_engine.py status" + extra_args);
        }
        else if (act == "sim-finetune")
        {
            std::string mode_val = (args.size() > 2 && args[1] == "--mode") ? args[2] : "air-gapped";
            return run_shell("python3 /home/kami/sentinel-matrix/tools/scenario_engine.py load scenarios/finetune_simulation.yaml --mode " + mode_val);
        }
        else if (act == "attack" && args.size() > 1)
        {
            return run_shell("cd /home/kami/sentinel-matrix && make attack-" + args[1]);
        }
        else
        {
            return run_shell("cd /home/kami/sentinel-matrix && make " + act);
        }
    }

    // -------------------------------------------------------------------------
    // [12. Cache Management]
    // -------------------------------------------------------------------------
    if (domain == "cache")
    {
        if (wants_help)
        {
            print_help_cache();
            return 0;
        }
        std::vector<std::string> c_args = {"cache"};
        c_args.insert(c_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", c_args);
    }

    // -------------------------------------------------------------------------
    // [13. Standalone Air-Gapped System Portability (.aryopack)]
    // -------------------------------------------------------------------------
    if (domain == "system")
    {
        if (args.empty() || wants_help)
        {
            print_help_system();
            return 0;
        }
        std::string act = args[0];
        if (act == "export")
        {
            std::string out_file = (args.size() > 1) ? args[1] : "sentinel_ecosystem.aryopack";
            return run_shell("sudo /home/kami/sentinel-stack/scripts/export_system.sh " + out_file);
        }
        if (act == "import" && args.size() >= 2)
        {
            std::string in_file = args[1];
            std::string tmp_extract = "/tmp/aryopack_import_" + std::to_string(getpid());
            std::string cmd = "mkdir -p " + tmp_extract + " && tar -xzf " + in_file + " -C " + tmp_extract +
                              " && sudo bash " + tmp_extract + "/import_system.sh && rm -rf " + tmp_extract;
            return run_shell(cmd);
        }
    }

    // -------------------------------------------------------------------------
    // [15. 5G/6G Wireless Network Slicing & UPF Guard]
    // -------------------------------------------------------------------------
    if (domain == "5g")
    {
        if (wants_help)
        {
            print_help_5g();
            return 0;
        }
        if (args.empty())
        {
            std::cerr << "[-] Error: 5G action required. Run 'aryo 5g --help'.\n";
            return 1;
        }

        if (args[0] == "blast-test")
        {
            std::string iface = (args.size() > 1) ? args[1] : "lo";
            std::string blaster = "/home/kami/sentinel-stack/harnesses/gtp_slice_blaster.py";
            return run_shell("python3 " + blaster + " --iface " + iface);
        }
        else
        {
            std::vector<std::string> ctl_args = {"5g"};
            ctl_args.insert(ctl_args.end(), args.begin(), args.end());
            forward_exec("sentinel-ctl", ctl_args);
        }
    }

    // -------------------------------------------------------------------------
    // [16. Live-SBOM Memory Integrity Engine]
    // -------------------------------------------------------------------------
    if (domain == "sbom")
    {
        if (wants_help)
        {
            print_help_sbom();
            return 0;
        }
        std::vector<std::string> ctl_args = {"sbom"};
        ctl_args.insert(ctl_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", ctl_args);
    }

    // -------------------------------------------------------------------------
    // [17. Orbital & Space-Based Telemetry Security Guard]
    // -------------------------------------------------------------------------
    if (domain == "space")
    {
        if (wants_help)
        {
            print_help_space();
            return 0;
        }
        if (args.empty() || args[0] == "status")
            return run_shell("ccsds-guard status");
        if (args[0] == "blast-sim")
            return run_shell("python3 /home/kami/sentinel-stack/harnesses/space_link_blaster.py");
        if (args[0] == "ccsds")
            forward_exec("ccsds-guard", {"status"});
        std::cerr << "[-] Error: Unknown space action. Run 'aryo space --help'.\n";
        return 1;
    }

    // -------------------------------------------------------------------------
    // [18. GenAI / LLM Prompt Injection Firewall (AI TRiSM)]
    // -------------------------------------------------------------------------
    if (domain == "trism")
    {
        if (wants_help)
        {
            print_help_trism();
            return 0;
        }
        std::vector<std::string> ctl_args = {"trism"};
        ctl_args.insert(ctl_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", ctl_args);
    }

    std::cerr << "[-] Error: Unknown domain 'aryo " << domain << "'. Run 'aryo --help'.\n";
    return 1;
}