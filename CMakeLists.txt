cmake_minimum_required(VERSION 3.25)

project(redasm-workspace C CXX)

add_subdirectory(core)
add_subdirectory(redasm)
add_subdirectory(loaders)
add_subdirectory(processors)
add_subdirectory(commands)
