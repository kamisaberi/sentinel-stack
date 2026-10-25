#include "common.hpp"
#include "help_manuals.hpp"
#include "domain_router.hpp"

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        print_global_help();
        return 0;
    }

    std::string domain = argv[1];

    if (domain == "-h" || domain == "--help" || domain == "help")
    {
        print_global_help();
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

    return dispatch_domain(domain, args);
}