#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <cstdlib>
#include <unistd.h>
#include <sys/wait.h>

namespace fs = std::filesystem;

static void print_banner()
{
    std::cout << "\033[1;36m"
              << "   ____  ______  __ ____ \n"
              << "  / __ \\/ __ \\ \\/ // __ \\\n"
              << " / /_/ / /_/ /\\  // /_/ /\n"
              << "/_/\\__,_/\\____/ /_/ \\____/ \n"
              << "\033[0m"
              << "\033[1mAryorithm Unified Active Defense & Research Master CLI (v2.5.0)\033[0m\n"
              << "Corporate: https://aryorithm.com | Hub: https://backend.aryorithm.com\n"
              << std::endl;
}

static void print_help()
{
    print_banner();
    std::cout << R"(Usage:
  aryo <domain> <action> [arguments]

Domains & Commands:

[1. Authentication & Registry Identity]
  aryo login --jwt <TOKEN> [--hub-url <url>]    Exchange JWT for API key & save credentials
  aryo whoami                                   Display active authenticated registry identity
  aryo auth login [email] [pass] [--url]        Authenticate with backend and save cloud session
  aryo auth register [email] [pass] [user]      Register a new user account with backend
  aryo auth status                              Display active cloud session on disk

[2. Appliance & Routing Lifecycle]
  aryo status                                   Inspect appliance health, TPM 2.0 & eBPF status
  aryo appliance sync <routes.yaml>             Audit dependencies and resolve packages/models
  aryo appliance check <routes.yaml>            Check if all dependencies are satisfied locally
  aryo appliance launch <routes.yaml>           Sync and launch Sentinel daemon in one step
  aryo appliance install <file.spkg>            Verify Ed25519 signature & deploy package
  aryo hardware status                          Inspect physical hardware profile & TPM 2.0
  aryo hardware enroll                          Enroll physical TPM 2.0 silicon identity token

[3. Stack & Systemd Services Management]
  aryo stack install                            Run master 6-tier installation pipeline
  aryo stack build                              Run topological DAG build across all tiers
  aryo stack verify                             Run 15-point system verification suite
  aryo stack uninstall                          Run interactive ecosystem uninstaller
  aryo stack purge                              Execute immediate full system purge (--yes)
  aryo stack env                                Audit system dependencies, compiler & venv
  aryo service start [sentinel|nexus|all]       Start systemd service(s)
  aryo service stop [sentinel|nexus|all]        Stop systemd service(s)
  aryo service restart [sentinel|nexus|all]     Restart systemd service(s)
  aryo service status [sentinel|nexus|all]      Display systemd service status
  aryo service logs [sentinel|nexus] [-f]       Stream journalctl service logs
  aryo service enable [sentinel|nexus|all]      Enable service(s) on boot
  aryo service disable [sentinel|nexus|all]     Disable service(s) on boot

[4. Universal Artifacts & .spkg Packaging]
  aryo artifact new <name> [rust|cpp|lua]       Scaffold a new extension package project
  aryo artifact keygen <prefix>                 Generate Ed25519 developer keypair
  aryo artifact pack [dir]                      Smart auto-pack directory into sealed .spkg
  aryo artifact pack-raw <key> <tier> <m> ...   Low-level 7-argument pack command
  aryo artifact inspect <file.spkg>             Inspect package header, tier & SLA metadata
  aryo artifact verify <pub_key> <file.spkg>    Verify Ed25519 Merkle signature
  aryo artifact extract-source <file> <out>     Extract plain-text source for audit
  aryo artifact test <file.spkg>                Run in-sandbox pre-flight test vector
  aryo artifact synthesize-vaccine <inbox> [o]  Synthesize sealed .spkg vaccine from honeynet inbox
  aryo publish <file> [--token <KEY>] [--url]   Publish .spkg, .onnx, .slab, .pcap to Hub



  
[5. Hub Registry Marketplace]
  aryo hub search [query]                       Search verified packages on hub catalog
  aryo hub inspect <file.spkg>                  Inspect package manifest & security audit
  aryo hub verify <pub_key> <pkg>               Verify Ed25519 signature of hub package
  aryo hub broadcast <file.spkg>                Broadcast sealed .spkg fleet-wide (< 50ms)
  aryo hub new <name> [tier]                    Scaffold package template on C2 node
  aryo pcap pull <slug>                         Pull certified malware PCAP into cache
  aryo dataset pull <slug>                      Pull zero-copy .slab dataset into cache
  aryo model pull <model_slug>                  Pull verified ONNX neural weights

[6. Fleet & Threat Administration]
  aryo fleet list                               List all connected edge appliance nodes
  aryo threat drop <IP>                         Broadcast instant sub-50ms eBPF drop
  aryo ota status|stage|advance|rollback        Manage neural model rollout lifecycle
  aryo report cmmc|scada                        Export CMMC 2.0 & IEC 62443 compliance audits

[7. Continual AI & Quantization]
  aryo forge run [--remote] [--endpoint <url>]  Execute adaptation cycle (local or remote GPU)
  aryo forge quantize --model <m> --output <o>  Convert FP32 model to INT8 QDQ ONNX (< 20 us)
  aryo forge finetune --base-model <m> --dataset <d> --output <o> [--remote]
                                                Fine-tune on new SLAB telemetry (local or remote GPU)

[8. SLAB Protocol Engine]
  aryo slab convert <in.csv> <out.slab> <dim>   Convert CSV to 0x534C4142 zero-copy binary
  aryo slab verify <file.slab>                  Verify binary SLAB dataset integrity
  aryo slab stream <file.slab> [port]           Stream zero-copy binary records at 65k+ EPS

[9. PCAP Capture Vault]
  aryo pcap pack <key> <manifest> <in> <out>    Sign and seal raw PCAP into .spcap container

[10. Research Lab (14 Scientific Modules)]
  aryo lab daemon [options]                     Launch C++20 research evaluation daemon
  aryo lab inspect-matrix [--nexus IP] [--plc IP] Real-time live tap & audit of running matrix grid
  aryo lab blast [-i iface] [-r eps] [-c cfg]   Wire-speed raw socket frame blaster
  aryo lab evasion [--evasion-mode] [--epsilon] Grammar-constrained adversarial mutator
  aryo lab drift [-c cfg]                       Continual learning task matrix evaluator
  aryo lab hil [-c cfg] [-t duration]           Closed-loop physical plant HIL co-simulator
  aryo lab fuzzer [-g gw] [-p plc] [-port 502]  Differential SCADA request smuggling fuzzer
  aryo lab fdia [-g gw] [-p plc] [-t duration]  Cross-modal causal deception orchestrator
  aryo lab quant [-c cfg] [-n samples]          Multi-silicon precision drift evaluator
  aryo lab pqc [-c cfg] [-p payload]            NIST PQC TLS 1.3 MTU fragmentation profiler
  aryo lab stateful [-t target] [-p 102]        Generative stateful SCADA session fuzzer
  aryo lab sidechannel [-c cfg] [-n samples]    Hardware power/EM side-channel analyzer
  aryo lab cbf [-c cfg]                         Control Barrier Function reachability verifier
  aryo lab federated [-c cfg]                   Federated AI Byzantine poisoning evaluator
  aryo lab patch-regression [-c cfg]            Exploit neutralization scorecard evaluator

[11. Digital Twin Range Mesh]
  aryo matrix up|down|restart|status|tui        Manage multi-container simulation mesh
  aryo matrix plc [-p 502] [-s 102] [-i 2404]   Launch standalone RK4 ODE mock PLC twin
  aryo matrix attack <scenario_name>            Replay malware attack across digital twin
  aryo matrix honeynet-autohunt [spool_dir]     Autonomous loop: harvest exploit, synthesize & broadcast vaccine

[12. Cache & Offline Assets]
  aryo cache list|clean|export|import           Manage local content-addressable cache

[13. Standalone Air-Gapped System Portability]
  aryo system export [output.aryopack]          Package complete ecosystem for offline USB transfer
  aryo system import <input.aryopack>           Restore complete operational ecosystem offline

[14. Licensing & Entitlements]
  aryo license apply <file.lic>                 Apply commercial license to /etc/sentinel/license.lic
  aryo license inspect <file.lic>               Inspect license entitlements, nodes & expiration

[15. Private 5G/6G Wireless Network Slicing & UPF Guard]
  aryo 5g status                                Inspect active 5G slice TEIDs & kernel violation drops
  aryo 5g enable [iface] [config.yaml]          Provision 3GPP slices into in-kernel eBPF driver
  aryo 5g blast-test [iface]                    Replay synthetic 5G GTP-U slice-hopping attack test


[16. Live-SBOM Memory Integrity Engine]
  aryo sbom generate                            Generate cryptographic Live-SBOM (/etc/sentinel/live_sbom.json)
  aryo sbom enforce                             Activate in-kernel W^X enforcement and sub-µs SIGKILL defense
  aryo sbom status                              Audit runtime process memory integrity & drift statistics
  aryo sbom test-drift                          Simulate fileless shellcode PROT_EXEC injection test drill

[17. Orbital & Space-Based Telemetry Security Guard (CCSDS / STANAG)]
  aryo space status                             Display space link telemetry, APID ACL & SLA status
  aryo space ccsds                              Inspect and verify live CCSDS 133.0-B-2 space packets
  aryo space blast-sim                          Replay synthetic LEO telemetry & TC injection attacks

[18. GenAI / LLM Prompt Injection Firewall (AI TRiSM)]
  aryo trism status                             Inspect AI TRiSM firewall status & sub-µs SLA
  aryo trism inspect --prompt "<text>"          Inspect prompt text for jailbreaks & injection vectors
  aryo trism test-jailbreak                     Run red-team benchmark across 4 injection classes
  aryo trism policy                             Display active OT Copilot tool governance policy
)" << std::endl;
}

[[noreturn]] static void forward_exec(const std::string &binary, const std::vector<std::string> &args)
{
    std::vector<char *> c_args;
    c_args.push_back(const_cast<char *>(binary.c_str()));
    for (const auto &a : args)
    {
        c_args.push_back(const_cast<char *>(a.c_str()));
    }
    c_args.push_back(nullptr);

    execvp(binary.c_str(), c_args.data());

    std::cerr << "\033[1;31m[-] Error: Failed to execute '" << binary << "'. Ensure it is installed in /usr/local/bin.\033[0m\n";
    exit(1);
}

static int run_shell(const std::string &cmd)
{
    return std::system(cmd.c_str());
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        print_help();
        return 0;
    }

    std::string domain = argv[1];

    if (domain == "-h" || domain == "--help" || domain == "help")
    {
        print_help();
        return 0;
    }

    if (domain == "-v" || domain == "--version" || domain == "version")
    {
        print_banner();
        return 0;
    }

    std::vector<std::string> args;
    for (int i = 2; i < argc; ++i)
    {
        args.emplace_back(argv[i]);
    }

    // -------------------------------------------------------------------------
    // [1. Auth & Identity]
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
    // [2. Appliance, Routing & Licensing]
    // -------------------------------------------------------------------------
    if (domain == "status")
    {
        forward_exec("sentinel-ctl", {"status"});
    }
    if (domain == "appliance" || domain == "license")
    {
        std::vector<std::string> lic_args = {domain};
        lic_args.insert(lic_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", lic_args);
    }
    if (domain == "hardware")
    {
        std::vector<std::string> hw_args = {"hardware"};
        hw_args.insert(hw_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", hw_args);
    }

    // -------------------------------------------------------------------------
    // [3. Stack & Systemd Services Management]
    // -------------------------------------------------------------------------
    if (domain == "stack")
    {
        if (args.empty())
        {
            std::cerr << "[-] Error: Subcommand required. (install, build, verify, uninstall, purge, env)\n";
            return 1;
        }
        std::string sub = args[0];
        if (sub == "install")
        {
            return run_shell("sudo /home/kami/sentinel-stack/install.sh");
        }
        else if (sub == "build")
        {
            return run_shell("/home/kami/sentinel-stack/build_all.sh");
        }
        else if (sub == "verify")
        {
            return run_shell("/home/kami/sentinel-stack/verify_stack.sh");
        }
        else if (sub == "uninstall")
        {
            return run_shell("sudo /home/kami/sentinel-stack/uninstall.sh");
        }
        else if (sub == "purge")
        {
            return run_shell("sudo /home/kami/sentinel-stack/uninstall.sh --yes");
        }
        else if (sub == "env")
        {
            std::cout << "\033[1;36m[*] Auditing Sentinel-Stack System Environment:\033[0m\n";
            std::cout << "  • Kernel Version   : " << run_shell("uname -r") << "\n";
            std::cout << "  • Python Virtualenv: " << (fs::exists("/opt/sentinel-stack/venv") ? "\033[1;32mINSTALLED\033[0m" : "\033[1;31mMISSING\033[0m") << "\n";
            std::cout << "  • eBPF Filter      : " << (fs::exists("/etc/sentinel/xdp_drop.o") ? "\033[1;32mREADY\033[0m" : "\033[1;31mMISSING\033[0m") << "\n";
            std::cout << "  • Central Cache    : " << (fs::exists("/var/cache/sentinel") ? "\033[1;32mONLINE\033[0m" : "\033[1;31mMISSING\033[0m") << "\n";
            return 0;
        }
    }

    if (domain == "service")
    {
        if (args.empty())
        {
            std::cerr << "[-] Error: Action required (start, stop, restart, status, logs, enable, disable)\n";
            return 1;
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
            std::cout << "[*] " << sys_cmd << "...\n";
            run_shell(sys_cmd);
        }
        return 0;
    }

    // -------------------------------------------------------------------------
    // [4. Universal Artifacts & .spkg Packaging]
    // -------------------------------------------------------------------------
    if (domain == "artifact")
    {
        forward_exec("sentinel-artifact", args);
    }
    if (domain == "publish")
    {
        std::vector<std::string> pub_args = {"publish"};
        pub_args.insert(pub_args.end(), args.begin(), args.end());
        forward_exec("sentinel-artifact", pub_args);
    }

    // -------------------------------------------------------------------------
    // [5. Hub Registry & Pulling]
    // -------------------------------------------------------------------------
    if (domain == "hub")
    {
        std::vector<std::string> hub_args = {"hub"};
        hub_args.insert(hub_args.end(), args.begin(), args.end());
        forward_exec("nexus-ctl", hub_args);
    }
    if (domain == "pcap")
    {
        if (!args.empty() && args[0] == "pack")
        {
            std::vector<std::string> p_args = {"pcap"};
            p_args.insert(p_args.end(), args.begin(), args.end());
            forward_exec("sentinel-artifact", p_args);
        }
        else
        {
            std::vector<std::string> p_args = {"pcap"};
            p_args.insert(p_args.end(), args.begin(), args.end());
            forward_exec("sentinel-ctl", p_args);
        }
    }
    if (domain == "dataset" || domain == "model")
    {
        std::vector<std::string> d_args = {domain};
        d_args.insert(d_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", d_args);
    }

    // -------------------------------------------------------------------------
    // [6. Fleet & Threat Administration]
    // -------------------------------------------------------------------------
    if (domain == "fleet" || domain == "threat" || domain == "ota" || domain == "report")
    {
        std::vector<std::string> n_args = {domain};
        n_args.insert(n_args.end(), args.begin(), args.end());
        forward_exec("nexus-ctl", n_args);
    }

    // -------------------------------------------------------------------------
    // [7. Continual AI & Quantization]
    // -------------------------------------------------------------------------
    if (domain == "forge")
    {
        forward_exec("forge-cli", args);
    }

    // -------------------------------------------------------------------------
    // [8. SLAB Protocol Engine]
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
    // [9. Research Lab Testbed (14 Scientific Modules)]
    // -------------------------------------------------------------------------
    if (domain == "lab")
    {
        if (args.empty())
        {
            std::cerr << "[-] Error: Action required (daemon, inspect-matrix, blast, evasion, drift, hil, fuzzer, fdia, quant, pqc, stateful, sidechannel, cbf, federated, patch-regression)\n";
            return 1;
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
        {
            return run_shell(venv_py + " " + h_dir + "/matrix_live_tap.py" + flag_str);
        }
        else if (act == "blast")
        {
            return run_shell(venv_py + " " + h_dir + "/socket_injector.py" + flag_str);
        }
        else if (act == "evasion")
        {
            return run_shell(venv_py + " " + h_dir + "/socket_injector.py --evasion-mode" + flag_str);
        }
        else if (act == "drift")
        {
            return run_shell(venv_py + " " + h_dir + "/drift_evaluator.py" + flag_str);
        }
        else if (act == "hil")
        {
            return run_shell(venv_py + " " + h_dir + "/hil_co_simulator.py" + flag_str);
        }
        else if (act == "fuzzer")
        {
            return run_shell(venv_py + " " + h_dir + "/scada_fuzzer.py" + flag_str);
        }
        else if (act == "fdia")
        {
            return run_shell(venv_py + " " + h_dir + "/fdia_orchestrator.py" + flag_str);
        }
        else if (act == "quant")
        {
            return run_shell(venv_py + " " + h_dir + "/quant_evaluator.py" + flag_str);
        }
        else if (act == "pqc")
        {
            return run_shell(venv_py + " " + h_dir + "/pqc_tunnel_profiler.py" + flag_str);
        }
        else if (act == "stateful")
        {
            return run_shell(venv_py + " " + h_dir + "/stateful_fuzzer.py" + flag_str);
        }
        else if (act == "sidechannel")
        {
            return run_shell(venv_py + " " + h_dir + "/sidechannel_analyzer.py" + flag_str);
        }
        else if (act == "cbf")
        {
            return run_shell(venv_py + " " + h_dir + "/cbf_reachability_evaluator.py" + flag_str);
        }
        else if (act == "federated")
        {
            return run_shell(venv_py + " " + h_dir + "/federated_poison_evaluator.py" + flag_str);
        }
        else if (act == "patch-regression")
        {
            return run_shell(venv_py + " " + h_dir + "/patch_regression_evaluator.py" + flag_str);
        }
        else
        {
            std::cerr << "[-] Error: Unknown lab action '" << act << "'\n";
            return 1;
        }
    }

    // -------------------------------------------------------------------------
    // [10. Cyber Range Digital Twin]
    // -------------------------------------------------------------------------
    if (domain == "matrix")
    {
        if (args.empty())
        {
            std::cerr << "[-] Error: Matrix action required (up, down, restart, status, tui, plc, attack <name>, test-blueprint)\n";
            return 1;
        }
        std::string act = args[0];
        if (act == "test-blueprint")
        {
            return run_shell("bash /home/kami/sentinel-stack/scripts/validate_blueprint_pipeline.sh");
        }
        else if (act == "plc")
        {
            std::vector<std::string> plc_args(args.begin() + 1, args.end());
            forward_exec("mock_plc", plc_args);
        }
        else if (act == "attack" && args.size() > 1)
        {
            return run_shell("cd /home/kami/sentinel-matrix && make attack-" + args[1]);
        }
        else if (act == "honeynet-autohunt")
        {
            std::string spool = (args.size() > 1) ? args[1] : "/var/run/sentinel/honeynet_spool";
            std::cout << "\033[1;36m[*] [Aryo Autohunt] Harvesting Honeynet inbox: " << spool << "\033[0m\n";
            std::string synth_cmd = "sentinel-artifact synthesize-vaccine " + spool + " /tmp/honeynet_vaccines";
            int ret = run_shell(synth_cmd);
            if (ret != 0)
            {
                std::cerr << "\033[1;31m[-] Error: Vaccine synthesis failed or inbox empty.\033[0m\n";
                return 1;
            }

            std::cout << "\033[1;32m[+] [Aryo Autohunt] Vaccine generated. Broadcasting fleet-wide via Nexus (< 50ms)...\033[0m\n";
            std::string bcast_cmd = "for f in /tmp/honeynet_vaccines/*/*.spkg; do "
                                    "  if [ -f \"$f\" ]; then "
                                    "    nexus-ctl hub broadcast \"$f\"; "
                                    "    break; "
                                    "  fi; "
                                    "done";
            return run_shell(bcast_cmd);
        }
        else
        {
            return run_shell("cd /home/kami/sentinel-matrix && make " + act);
        }
    }

    // -------------------------------------------------------------------------
    // [11. Cache & Offline Assets]
    // -------------------------------------------------------------------------
    if (domain == "cache")
    {
        std::vector<std::string> c_args = {"cache"};
        c_args.insert(c_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", c_args);
    }

    // -------------------------------------------------------------------------
    // [13. Standalone Air-Gapped System Portability (.aryopack)]
    // -------------------------------------------------------------------------
    if (domain == "system")
    {
        if (args.empty())
        {
            std::cerr << "[-] Error: Action required (export, import)\n";
            return 1;
        }
        std::string act = args[0];
        if (act == "export")
        {
            std::string out_file = (args.size() > 1) ? args[1] : "sentinel_ecosystem.aryopack";
            return run_shell("sudo /home/kami/sentinel-stack/scripts/export_system.sh " + out_file);
        }
        else if (act == "import")
        {
            if (args.size() < 2)
            {
                std::cerr << "[-] Error: Archive path required. Usage: aryo system import <bundle.aryopack>\n";
                return 1;
            }
            std::string in_file = args[1];
            if (!fs::exists(in_file))
            {
                std::cerr << "[-] Error: Archive file not found: " << in_file << "\n";
                return 1;
            }
            std::string tmp_extract = "/tmp/aryopack_import_" + std::to_string(getpid());
            std::string cmd = "mkdir -p " + tmp_extract + " && tar -xzf " + in_file + " -C " + tmp_extract +
                              " && sudo bash " + tmp_extract + "/import_system.sh && rm -rf " + tmp_extract;
            return run_shell(cmd);
        }
        else
        {
            std::cerr << "[-] Error: Unknown system action '" << act << "'. Run 'aryo --help'.\n";
            return 1;
        }
    }

    // -------------------------------------------------------------------------
    // [14. Private 5G/6G Wireless Network Slicing & UPF Guard]
    // -------------------------------------------------------------------------
    if (domain == "5g")
    {
        if (args.empty())
        {
            std::cerr << "[-] Error: 5G action required (status, enable, blast-test)\n";
            return 1;
        }
        std::string act = args[0];
        if (act == "blast-test")
        {
            std::string iface = (args.size() > 1) ? args[1] : "lo";
            std::string venv_py = "/opt/sentinel-stack/venv/bin/python3";
            std::string blaster = "/opt/sentinel-stack/harnesses/gtp_slice_blaster.py";
            if (!fs::exists(blaster))
                blaster = "/home/kami/sentinel-stack/harnesses/gtp_slice_blaster.py";
            return run_shell(venv_py + " " + blaster + " --iface " + iface);
        }
        else
        {
            std::vector<std::string> ctl_args = {"5g"};
            ctl_args.insert(ctl_args.end(), args.begin(), args.end());
            forward_exec("sentinel-ctl", ctl_args);
        }
    }

    // -------------------------------------------------------------------------
    // [15. Live-SBOM Memory Integrity Engine]
    // -------------------------------------------------------------------------
    if (domain == "sbom")
    {
        std::vector<std::string> ctl_args = {"sbom"};
        ctl_args.insert(ctl_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", ctl_args);
    }

    // -------------------------------------------------------------------------
    // [16. Orbital & Space-Based Telemetry Security Guard]
    // -------------------------------------------------------------------------
    if (domain == "space")
    {
        if (args.empty() || args[0] == "status")
        {
            return run_shell("ccsds-guard status");
        }
        else if (args[0] == "blast-sim")
        {
            std::string blaster = "/home/kami/sentinel-stack/harnesses/space_link_blaster.py";
            return run_shell("python3 " + blaster);
        }
        else if (args[0] == "ccsds")
        {
            std::vector<std::string> c_args = {"status"};
            forward_exec("ccsds-guard", c_args);
        }
        else
        {
            std::cerr << "[-] Error: Unknown space action. Run 'aryo space status' or 'aryo space blast-sim'.\n";
            return 1;
        }
    }
    // -------------------------------------------------------------------------
    // [17. GenAI / LLM Prompt Injection Firewall (AI TRiSM)]
    // -------------------------------------------------------------------------
    if (domain == "trism")
    {
        std::vector<std::string> ctl_args = {"trism"};
        ctl_args.insert(ctl_args.end(), args.begin(), args.end());
        forward_exec("sentinel-ctl", ctl_args);
    }

    std::cerr << "[-] Error: Unknown command 'aryo " << domain << "'. Run 'aryo --help' for usage.\n";
    return 1;
}