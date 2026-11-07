#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <cstdlib>
#include <unistd.h>
#include <sys/wait.h>

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