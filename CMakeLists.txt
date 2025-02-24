cmake_minimum_required(VERSION 3.28...4.0)

project(Boost-CMake LANGUAGES CXX VERSION 1.87.0.1)

if(PROJECT_IS_TOP_LEVEL)
    message(STATUS "PROJECT_IS_TOP_LEVEL")
    option(BOOST_BUILD_ALL "Do build all targets" ON)
    option(BUILD_TESTING "Do build all tests" ON)
endif()

option(
    BUILD_SHARED_LIBS
    "A standard CMake variable that determines whether to build shared or static libraries. Defaults to OFF"
    ON
)

set(CMAKE_UNITY_BUILD ON)
set(CMAKE_INSTALL_MESSAGE LAZY)
set(CMAKE_SKIP_TEST_ALL_DEPENDENCY OFF)

if(CMAKE_SKIP_INSTALL_RULES)
    set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY ON)
    set(EXCLUDE_FROM_ALL EXCLUDE_FROM_ALL)
endif()

# NOTE: Use the FOLDER target property to organize targets into folders.
set_property(GLOBAL PROPERTY USE_FOLDERS TRUE)

# ensure that the debug and release builds use different names for the libraries that will be installed.
set(CMAKE_DEBUG_POSTFIX -d)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(BOOST_LIBS_REQUIRED headers)
set(BOOST_EXCLUDE_LIBRARIES
    serialization
    iostreams
    timer
    locale
    log
    graph
    property_tree
    wave
)

if(PROJECT_IS_TOP_LEVEL AND NOT BOOST_BUILD_ALL)
    # Compiled libs without warnings OSX with clang v19.1.7
    list(
        APPEND
        BOOST_INCLUDE_LIBRARIES
        ${BOOST_LIBS_REQUIRED}
        asio
        atomic
        chrono
        exception
        filesystem
        program_options
        regex
        system
        thread
    )
endif()

set(BOOST_LIBS_OPTIONAL
    container
    context
    coroutine
    date_time
    exception
    fiber
    json
    math
    random
    test
    type_erasure
    CACHE STRING
    "Boost libs to be compiled"
)

if(BOOST_BUILD_ALL)
    set(BOOST_INCLUDE_LIBRARIES)
else()
    list(APPEND BOOST_INCLUDE_LIBRARIES asio)
    list(APPEND BOOST_INCLUDE_LIBRARIES headers)
    list(REMOVE_DUPLICATES BOOST_INCLUDE_LIBRARIES)
endif()

enable_testing()

# ---- Add/prepare dependency handling via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

set(BOOST_SUBDIR boost_1_87_0)
if(EXISTS "$ENV{CPM_SOURCE_CACHE}/${BOOST_SUBDIR}")
    set(FETCHCONTENT_SOURCE_DIR_BOOST
        "$ENV{CPM_SOURCE_CACHE}/${BOOST_SUBDIR}"
        CACHE PATH
        "Boost source DIR"
    )
endif()
if(FETCHCONTENT_SOURCE_DIR_BOOST)
    set(CPM_Boost_SOURCE
        ${FETCHCONTENT_SOURCE_DIR_BOOST}
        CACHE PATH
        "Manual override"
    )
endif()

set(BOOST_VERSION 1.87.0)
set(BOOST_URL
    "https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}-cmake.7z"
    CACHE STRING
    "Boost download URL"
)
set(BOOST_URL_SHA256
    "61d61a3f33283bab8f3736745a4e47c37141f07e413986cd05d1f942c69d529a"
    CACHE STRING
    "Boost download URL SHA256 checksum"
)

# ---- Add Boost source tar archive via FetchContent ----
include(FetchContent)
FetchContent_Declare(
    Boost
    URL ${BOOST_URL}
    URL_HASH SHA256=${BOOST_URL_SHA256}
    DOWNLOAD_EXTRACT_TIMESTAMP ON
    ${EXCLUDE_FROM_ALL}
    SYSTEM
)

FetchContent_GetProperties(Boost)
if(NOT Boost_POPULATED)
    message(STATUS "Fetching Boost")
    FetchContent_MakeAvailable(Boost)
    message(STATUS "Fetching Boost - done")
    set(BOOST_SOURCE ${boost_SOURCE_DIR})

    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION})
        find_package(Patch)
        if(Patch_FOUND)
            message("Patch found: ${Patch_EXECUTABLE}")
            message("Patching Boost")
            if(
                EXISTS
                    ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/archive-01.patch
            )
                execute_process(
                    COMMAND
                        ${Patch_EXECUTABLE} -N -p1 -i
                        ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/archive-01.patch
                    WORKING_DIRECTORY ${BOOST_SOURCE}/boost/archive
                    COMMAND_ECHO STDOUT
                )
            endif()
            if(
                EXISTS
                    ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/thread_future-01.patch
            )
                execute_process(
                    COMMAND
                        ${Patch_EXECUTABLE} -N -p1 -i
                        ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/thread_future-01.patch
                    WORKING_DIRECTORY ${BOOST_SOURCE}/boost
                    COMMAND_ECHO STDOUT
                )
            endif()
            if(
                EXISTS
                    ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/serialization-01.patch
            )
                execute_process(
                    COMMAND
                        ${Patch_EXECUTABLE} -N -p1 -i
                        ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/serialization-01.patch
                    WORKING_DIRECTORY ${BOOST_SOURCE}/libs/serialization
                    COMMAND_ECHO STDOUT
                )
            endif()
            if(
                EXISTS
                    ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/filesystem-01.patch
            )
                execute_process(
                    COMMAND
                        ${Patch_EXECUTABLE} -N -p1 -i
                        ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/filesystem-01.patch
                    WORKING_DIRECTORY ${BOOST_SOURCE}/libs/filesystem
                    COMMAND_ECHO STDOUT
                )
            endif()
            if(
                EXISTS
                    ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/date_time-01.patch
            )
                execute_process(
                    COMMAND
                        ${Patch_EXECUTABLE} -N -p2 -i
                        ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/date_time-01.patch
                    WORKING_DIRECTORY ${BOOST_SOURCE}
                    COMMAND_ECHO STDOUT
                )
            endif()
            if(
                EXISTS
                    ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/date_time-02.patch
            )
                execute_process(
                    COMMAND
                        ${Patch_EXECUTABLE} -N -R -p1 -i
                        ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/date_time-02.patch
                    WORKING_DIRECTORY ${BOOST_SOURCE}/libs/date_time
                    COMMAND_ECHO STDOUT
                )
            endif()
            message("Patching Boost - done")
        endif()
    endif()
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

# FIXME: include(CheckBoostVersion)
message(STATUS "Boost found: ${BOOST_VERSION} ${BOOST_SOURCE}")

include(ccache)

# include(StandaloneBuild)
# include(PlatformDetect)
# include(AddBoostLib)
# include(AddBoostTest)

configure_file(
    cmake/Modules/ccache.cmake
    ${BOOST_SOURCE}/tools/cmake/include/ccache.cmake
    COPYONLY
)

#############################################################
# TODO(CK): Move this to libs/header.cmake in the right file
find_package(Threads)

# Compilation options required by all platforms
target_compile_definitions(
    boost_headers
    INTERFACE $<$<CONFIG:Release>:BOOST_DISABLE_ASSERT> BOOST_ASIO_NO_DEPRECATED
    #XXX BOOST_THREAD_VERSION=5
    #XXX BOOST_THREAD_USES_CHRONO
    #XXX BOOST_THREAD_PROVIDES_EXECUTORS
)
target_link_libraries(boost_headers INTERFACE Threads::Threads)
# target_compile_definitions(boost_headers INTERFACE BOOST_BIND_GLOBAL_PLACEHOLDERS)
# add_library(Boost::boost ALIAS boost_headers)
#############################################################

# if(UNIX AND BOOST_STANDALONE)
#   # TODO(CK): too many deprecated warnings!
#   if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
#     target_compile_options(boost INTERFACE -Wno-deprecated-copy)
#   endif()
#   if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND CMAKE_CXX_COMPILER_VERSION GREATER_EQUAL 19.0)
#     target_compile_options(
#       boost INTERFACE -Wno-deprecated-copy-dtor -Wno-newline-eof -Wno-deprecated-copy-with-user-provided-copy
#     )
#   endif()
#   if(USE_APPLE)
#     target_compile_options(boost INTERFACE -Wno-deprecated-declarations)
#   endif()
# endif()

# ---- Install rules ----

if(CMAKE_SKIP_INSTALL_RULES)
    return()
endif()

include(AddUninstallTarget)
include(CPack)
