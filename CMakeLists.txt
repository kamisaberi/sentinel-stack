cmake_minimum_required(VERSION 3.20)
project(sentinel-stack VERSION 2.5.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Optimization & Hardening Compiler Flags
add_compile_options(-O3 -Wall -Wextra -pthread)

# Locate Native SSFS Engine (Tier 0 Foundation)
find_library(SENTINELFS_LIB NAMES sentinelfs PATHS /usr/local/lib REQUIRED)

# Define Master CLI Binary Target
add_executable(aryo
    src/aryo.cpp
)

# Target-Specific Include Directories
target_include_directories(aryo PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    /usr/local/include
)

# Link Against Tier 0 Sovereign Filesystem Engine
target_link_libraries(aryo PRIVATE
    ${SENTINELFS_LIB}
    pthread
)

# System Installation Target
install(TARGETS aryo DESTINATION /usr/local/bin)