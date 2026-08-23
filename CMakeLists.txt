cmake_minimum_required(VERSION 3.30...4.4)

include(cmake/prelude.cmake)

# CMake 4.4 does not record MSVC as supporting CXX26. Compiler detection occurs
# during project(), before CMAKE_CXX_COMPILER_ID is available, so temporarily
# allow standard decay and restore the requested strict setting afterward.
set(beman_bounds_test_restore_required OFF)
if(
    CMAKE_VERSION VERSION_LESS 4.5
    AND CMAKE_CXX_STANDARD EQUAL 26
    AND (NOT DEFINED CMAKE_CXX_STANDARD_REQUIRED OR CMAKE_CXX_STANDARD_REQUIRED)
)
    set(beman_bounds_test_restore_required ON)
    set(CMAKE_CXX_STANDARD_REQUIRED OFF)
endif()

# gersemi: off
project(Boost-CMake LANGUAGES CXX VERSION 1.92.0.3)
# gersemi: on

# Work around missing MSVC C++26 bookkeeping in CMake through version 4.4.
if(beman_bounds_test_restore_required)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(CMAKE_CXX_STANDARD_REQUIRED OFF)
    else()
        set(CMAKE_CXX_STANDARD_REQUIRED ON)
    endif()
endif()
unset(beman_bounds_test_restore_required)

# Neither of these two are technically needed, but they make the expectation clear
if(NOT DEFINED CMAKE_CXX_EXTENSIONS)
    set(CMAKE_CXX_EXTENSIONS OFF)
endif()

if(NOT DEFINED CMAKE_CXX_STANDARD_REQUIRED)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

if(PROJECT_IS_TOP_LEVEL)
    option(BUILD_TESTING "Build the tests." OFF)
    if(UNIX)
        option(BOOST_BUILD_ALL "Do build all boost libs" ON)
    endif()
    option(BOOST_USE_MODULES "Do build with CXX_MODULES if possible" OFF)
    if(BOOST_USE_MODULES)
        set(CMAKE_CXX_SCAN_FOR_MODULES ON)
        if(NOT CMAKE_CXX_STANDARD GREATER_EQUAL 23)
            set(CMAKE_CXX_MODULE_STD OFF)
        endif()
    else()
        set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
    endif()

    set(BOOST_BUILD_TESTING ${BUILD_TESTING})
    set(Boost_VERBOSE ON)
    set(Boost_DEBUG OFF)
    set(EXCLUDE_FROM_ALL)

    enable_testing()
endif()

option(
    BUILD_SHARED_LIBS
    "A standard CMake variable that determines whether to build shared or static libraries. Defaults to ON"
    ON
)
if(BOOST_USE_MODULES AND NOT UNIX)
    set(BUILD_SHARED_LIBS OFF)
endif()

if(NOT BOOST_USE_MODULES AND UNIX)
    message(STATUS "Use CMAKE_UNITY_BUILD")
    set(CMAKE_UNITY_BUILD ON)
endif()

set(CMAKE_INSTALL_MESSAGE LAZY)
set(CMAKE_SKIP_TEST_ALL_DEPENDENCY OFF)

if(CMAKE_SKIP_INSTALL_RULES)
    set(EXCLUDE_FROM_ALL EXCLUDE_FROM_ALL)
    set(BOOST_SKIP_INSTALL_RULES ${CMAKE_SKIP_INSTALL_RULES})
else()
    set(EXCLUDE_FROM_ALL)
    set(BOOST_SKIP_INSTALL_RULES OFF)
    set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY ON)
endif()

# NOTE: Use the FOLDER target property to organize targets into folders.
set_property(GLOBAL PROPERTY USE_FOLDERS TRUE)

# ensure that the debug and release builds use different names for the libraries that will be installed.
set(CMAKE_DEBUG_POSTFIX -d)
set(stageDir ${CMAKE_CURRENT_BINARY_DIR}/stage)
include(GNUInstallDirs)

# The following code collect binaries under a stage subdirectory of the current binary directory
# unless a parent project overrides this.
if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_BINDIR})
endif()
if(NOT CMAKE_LIBRARY_OUTPUT_DIRECTORY)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_LIBDIR})
endif()
if(NOT CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${stageDir}/${CMAKE_INSTALL_LIBDIR})
endif()

set(BOOST_LIBS_REQUIRED headers)
set(BOOST_EXCLUDE_LIBRARIES
    cobalt
    dll # FIXME: use BOOST_USE_MODULES, but does not build! CK
    fiber
    graph # FIXME: takes to long to build! CK
    iostreams
    locale
    log
    timer
    wave
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(BOOST_USE_MODULES)
        # FIXME: stacktrace use private modules! CK
        list(APPEND BOOST_EXCLUDE_LIBRARIES stacktrace)
        # TODO: contract and program_options does not build with any module
        # at least on APPLE with g++-16!
        list(APPEND BOOST_EXCLUDE_LIBRARIES contract program_options)
    endif()
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT CMAKE_CXX_MODULE_STD)
    # FIXME: date_time library, deps on lexical_cast
    # but asio, thread depends on date_time!
    # and process on asio
    # XXX list(APPEND BOOST_EXCLUDE_LIBRARIES lexical_cast date_time asio)
endif()
if(MSVC)
    # FIXME: any, and stacktrace fails to build with modules on Windows! CK
    list(APPEND BOOST_EXCLUDE_LIBRARIES stacktrace)
    # TODO: contract and program_options does not build with any module
    # on Windows
    list(APPEND BOOST_EXCLUDE_LIBRARIES contract program_options)
endif()

if(PROJECT_IS_TOP_LEVEL AND NOT BOOST_BUILD_ALL)
    # NOTE: Compiled libs without warnings OSX with clang v22.1.7! CK
    list(
        APPEND BOOST_INCLUDE_LIBRARIES
        ${BOOST_LIBS_REQUIRED}
        any # use BOOST_USE_MODULES, deps on type_index
        asio
        atomic
        beast # NOTE: interface, but deps on type_index! CK
        stacktrace # use BOOST_USE_MODULES
        chrono
        container
        contract # TODO(CK): library, deps on any!
        conversion # use BOOST_USE_MODULES
        coroutine
        exception
        filesystem # FIXME: Warnings with g++-16 on OSX! CK
        geometry # NOTE: interface, but deps on any
        graph # FIXME: deps on any, and serialization! CK
        json
        lexical_cast # use BOOST_USE_MODULES
        math
        optional
        parser # interface, but deps on type_index! CK
        pfr # use BOOST_USE_MODULES
        process # deps on type_index
        program_options # TODO(CK): library, deps on any!
        property_map # NOTE: interface, but deps on any! CK
        property_tree # NOTE: interface, but deps on any! CK
        regex
        serialization
        signals2
        system
        test
        thread
        type_index # use BOOST_USE_MODULES
        variant2
    )
endif()

if(BOOST_BUILD_ALL)
    set(BOOST_INCLUDE_LIBRARIES)
else()
    list(APPEND BOOST_INCLUDE_LIBRARIES asio)
    list(APPEND BOOST_INCLUDE_LIBRARIES headers)
    list(REMOVE_DUPLICATES BOOST_INCLUDE_LIBRARIES)
endif()
list(REMOVE_DUPLICATES BOOST_EXCLUDE_LIBRARIES)

# ---- Add/prepare dependency handling via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

set(BOOST_SUBDIR boost-1.92.0)
if(EXISTS "$ENV{CPM_SOURCE_CACHE}/${BOOST_SUBDIR}")
    set(FETCHCONTENT_SOURCE_DIR_BOOST
        "$ENV{CPM_SOURCE_CACHE}/${BOOST_SUBDIR}"
        CACHE PATH
        "Boost cached source DIR"
    )
endif()
if(FETCHCONTENT_SOURCE_DIR_BOOST)
    set(CPM_Boost_SOURCE ${FETCHCONTENT_SOURCE_DIR_BOOST} CACHE PATH "CPM Manual override")
endif()

set(BOOST_VERSION 1.92.0)
set(BOOST_FILE_VERSION ${BOOST_VERSION})
set(BOOST_URL
    "https://github.com/boostorg/boost/releases/download/boost-${BOOST_FILE_VERSION}/boost-${BOOST_FILE_VERSION}-cmake.7z"
    CACHE STRING
    "Boost download URL"
)
set(BOOST_URL_SHA256
    "158852d45a7ce23de167a3dc2e57b04490829b233f06e835d5c81a65547ef68b"
    CACHE STRING
    "Boost download URL SHA256 checksum"
)

#############################################################
if(
    APPLE
    AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU"
    AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 16
    AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 17
    AND CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm64|aarch64)$"
)
    # FIXME: GCC 16 on Darwin ARM64 loses boost::ulong_long_type from
    # Boost.Config when sources are compiled with -fmodules-ts.
    add_compile_definitions(BOOST_HAS_LONG_LONG)
endif()
#############################################################

# ---- Add Boost source tar archive via FetchContent ----
include(FetchContent)
set(BOOST_PATCH_DIR "${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}")
set(BOOST_PATCHES "${BOOST_PATCH_DIR}/TheBigBoost.patch")

FetchContent_Declare(
    Boost
    URL ${BOOST_URL}
    URL_HASH SHA256=${BOOST_URL_SHA256}
    PATCH_COMMAND git apply -p0 ${BOOST_PATCHES}
    SYSTEM
    ${EXCLUDE_FROM_ALL}
)

FetchContent_MakeAvailable(Boost)
set(BOOST_SOURCE ${Boost_SOURCE_DIR})
message(STATUS "Boost_SOURCE_DIR=${Boost_SOURCE_DIR}")

# TODO(CK): should be a function instead use of BOOST_SOURCE and BOOST_VERSION
include(cmake/CheckBoostVersion.cmake)

message(STATUS "Boost found: ${BOOST_VERSION} ${BOOST_SOURCE}")
# TODO(CK): one possible workaround to not call the PATCH_COMMAND while each RERUN_CMAKE
set(FETCHCONTENT_SOURCE_DIR_BOOST
    "${Boost_SOURCE_DIR}"
    CACHE PATH
    "Boost patched source DIR"
    FORCE
)

#############################################################

include(cmake/ccache.cmake)
configure_file(cmake/ccache.cmake ${BOOST_SOURCE}/tools/cmake/include/ccache.cmake COPYONLY)

list(APPEND CMAKE_MODULE_PATH ${BOOST_SOURCE}/tools/cmake/include)
include(BoostTestJamfile OPTIONAL RESULT_VARIABLE HAVE_BOOST_TEST)
if(HAVE_BOOST_TEST)
    message(STATUS "We found boost ctest module: ${HAVE_BOOST_TEST}")
endif()

#############################################################

find_package(Threads)

# Compilation options required for all platforms
target_compile_definitions(
    boost_headers
    INTERFACE
        $<$<CONFIG:Release>:BOOST_DISABLE_ASSERT>
        BOOST_ASIO_NO_DEPRECATED
        BOOST_HAS_LONG_LONG
)
target_link_libraries(boost_headers INTERFACE Threads::Threads)

#############################################################

# ---- usage example and test ----

if(PROJECT_IS_TOP_LEVEL)
    add_subdirectory(examples)
endif()

# ---- Install rules ----

if(CMAKE_SKIP_INSTALL_RULES)
    return()
endif()

set(CPACK_GENERATOR "TGZ")
include(CPack)

include(AddUninstallTarget)
