cmake_minimum_required(VERSION 3.4.1)

project(emulator_core)

set(CMAKE_CXX_STANDARD 17)

add_library(emulator_core SHARED
    emulator_core.cpp
    z80.cpp
    vdp.cpp
    psg.cpp
)

find_library(log-lib log)
find_library(android-lib android)

target_link_libraries(emulator_core ${log-lib} ${android-lib})
