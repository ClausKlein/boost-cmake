cmake_minimum_required(VERSION 3.28...4.4)

project(gcc_typeinfo_module_reproducer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)

add_library(typeinfo_module)

target_sources(typeinfo_module PUBLIC FILE_SET CXX_MODULES FILES m.cppm)

add_executable(typeinfo_module_test main.cpp)

target_link_libraries(typeinfo_module_test PRIVATE typeinfo_module)

enable_testing()

add_test(NAME typeinfo_module_test COMMAND typeinfo_module_test)
