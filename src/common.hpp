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