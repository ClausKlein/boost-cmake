cmake_minimum_required(VERSION 3.28...4.4)

project(gcc_typeinfo_module_reproducer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)

##################################################
include(FetchContent)
FetchContent_Declare(
    boost-cmake
    URL
        https://github.com/ClausKlein/boost-cmake/archive/refs/tags/v1.92.0-rc3.tar.gz
    URL_HASH
        SHA256=bbcd4de95670755b39f874ae7efe307beef19c6b53c9736c037ebd794e10bab0
    DOWNLOAD_EXTRACT_TIMESTAMP ON
    PATCH_COMMAND
        patch --backup --forward -p1 -i
        ${CMAKE_CURRENT_SOURCE_DIR}/readme.patch
    # EXCLUDE_FROM_ALL
    SYSTEM
    SOURCE_SUBDIR tests
)
FetchContent_MakeAvailable(boost-cmake)

return()
##################################################

add_library(typeinfo_module)

target_sources(typeinfo_module PUBLIC FILE_SET CXX_MODULES FILES m.cppm)

add_executable(typeinfo_module_test main.cpp)

target_link_libraries(typeinfo_module_test PRIVATE typeinfo_module)

enable_testing()

add_test(NAME typeinfo_module_test COMMAND typeinfo_module_test)
