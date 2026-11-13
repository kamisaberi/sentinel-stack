#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <cstdlib>
#include <unistd.h>
#include <sys/wait.h>
#include <set>
#include <memory>
#include <array>

namespace fs = std::filesystem;

inline void print_banner()
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

[[noreturn]] inline void forward_exec(const std::string &binary, const std::vector<std::string> &args)
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

inline int run_shell(const std::string &cmd)
{
    return std::system(cmd.c_str());
}

inline bool is_help_flag(const std::string &arg)
{
    return (arg == "-h" || arg == "--help" || arg == "help");
}

// Portable repository & workspace path resolver (works for ANY user/system)
inline fs::path get_repo_dir(const std::string &repo_name)
{
    std::error_code ec;

    // 1. Check system production installation path first
    fs::path sys_path = fs::path("/opt") / repo_name;
    if (fs::exists(sys_path, ec) && !ec)
        return sys_path;

    // 2. Check current user's home directory: $HOME/<repo_name>
    const char *home_env = std::getenv("HOME");
    if (home_env)
    {
        fs::path user_repo = fs::path(home_env) / repo_name;
        if (fs::exists(user_repo, ec) && !ec)
            return user_repo;
    }

    // 3. Check relative to current working directory
    fs::path cur_rel = fs::current_path() / repo_name;
    if (fs::exists(cur_rel, ec) && !ec)
        return cur_rel;

    fs::path parent_rel = fs::current_path() / ".." / repo_name;
    if (fs::exists(parent_rel, ec) && !ec)
        return parent_rel;

    // Fallback default
    return home_env ? (fs::path(home_env) / repo_name) : fs::path("/opt") / repo_name;
}

// Portable python research harness resolver
inline fs::path resolve_harness(const std::string &script_name)
{
    std::error_code ec;
    std::vector<fs::path> candidates = {
        fs::path("/opt/sentinel-stack/harnesses") / script_name,
        get_repo_dir("sentinel-lab") / "harness" / script_name,
        get_repo_dir("sentinel-lab") / "harnesses" / script_name,
        get_repo_dir("sentinel-stack") / "harnesses" / script_name
    };

    for (const auto &p : candidates)
    {
        if (fs::exists(p, ec) && !ec)
            return p;
    }
    // Return system default if not yet found
    return fs::path("/opt/sentinel-stack/harnesses") / script_name;
}

// -----------------------------------------------------------------------------
// DYNAMIC ECOSYSTEM PLUGIN DISCOVERY & DISPATCH
// -----------------------------------------------------------------------------
inline std::vector<std::pair<std::string, std::string>> discover_aryo_plugins()
{
    std::vector<std::pair<std::string, std::string>> plugins;
    std::set<std::string> seen_domains;
    const std::vector<std::string> search_dirs = {"/usr/local/bin", "/usr/bin", "/etc/sentinel/plugins"};

    for (const auto &dir : search_dirs)
    {
        std::error_code ec;
        if (!fs::exists(dir, ec) || !fs::is_directory(dir, ec))
            continue;

        for (const auto &entry : fs::directory_iterator(dir, ec))
        {
            if (!entry.is_regular_file(ec))
                continue;

            const std::string filename = entry.path().filename().string();
            if (filename.rfind("aryo-", 0) == 0 && filename.length() > 5)
            {
                const std::string domain = filename.substr(5);
                if (seen_domains.contains(domain))
                    continue;

                seen_domains.insert(domain);

                // Query plugin description via --plugin-desc
                std::string desc = "External ecosystem extension";
                const std::string cmd = entry.path().string() + " --plugin-desc 2>/dev/null";
                std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd.c_str(), "r"), pclose);
                if (pipe)
                {
                    std::array<char, 256> buffer;
                    if (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr)
                    {
                        desc = buffer.data();
                        while (!desc.empty() && (desc.back() == '\n' || desc.back() == '\r'))
                            desc.pop_back();
                    }
                }
                plugins.emplace_back(domain, desc);
            }
        }
    }
    return plugins;
}

inline bool find_and_exec_plugin(const std::string &domain, const std::vector<std::string> &args)
{
    const std::string bin_name = "aryo-" + domain;
    const std::vector<std::string> search_dirs = {"/usr/local/bin", "/usr/bin", "/etc/sentinel/plugins"};

    for (const auto &dir : search_dirs)
    {
        const fs::path p = fs::path(dir) / bin_name;
        std::error_code ec;
        if (fs::exists(p, ec) && (access(p.c_str(), X_OK) == 0))
        {
            forward_exec(p.string(), args);
        }
    }
    return false;
}