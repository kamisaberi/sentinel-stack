cmake_minimum_required(VERSION 3.20)
project(sentinel-stack VERSION 2.5.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Optimization & Warning Flags
add_compile_options(-O3 -Wall -Wextra -pthread)

# Include header modules (common.hpp, help_manuals.hpp, domain_router.hpp)
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Define Master CLI Binary Target
add_executable(aryo
    src/aryo.cpp
)

# System Installation Target
install(TARGETS aryo DESTINATION /usr/local/bin)