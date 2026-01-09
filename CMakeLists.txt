cmake_minimum_required(VERSION 3.30...4.2)

project(Boost-CMake LANGUAGES CXX VERSION 1.90.0.1)

if(PROJECT_IS_TOP_LEVEL)
    option(BUILD_TESTING "Build the tests." OFF)
    if(UNIX)
        option(BOOST_BUILD_ALL "Do build all boost libs" ON)
        option(BOOST_USE_MODULES "Do build with CXX_MODULES if possible" ON)
        set(CMAKE_CXX_SCAN_FOR_MODULES ON)
        set(CMAKE_CXX_MODULE_STD OFF) # TODO(CK): not yet!
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

message(STATUS "Use CMAKE_UNITY_BUILD")
set(CMAKE_UNITY_BUILD ON)

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
    fiber
    # XXX graph # deps on any, serialization
    iostreams
    locale
    log
    json
    # XXX serialization # FIXME: fails with CMAKE_UNITY_BUILD! CK
    timer
    wave
)

if(PROJECT_IS_TOP_LEVEL AND NOT BOOST_BUILD_ALL)
    # NOTE: Compiled libs without warnings OSX with clang v21.1.7! CK
    list(
        APPEND BOOST_INCLUDE_LIBRARIES
        ${BOOST_LIBS_REQUIRED}
        any # use BOOST_USE_MODULES, deps on type_index
        asio
        atomic
        beast # deps on type_index
        chrono
        container
        contract # deps on any
        coroutine
        exception
        filesystem # FIXME: Warnings with g++-15 on OSX! CK
        geometry # deps on any
        graph # deps on any, serialization
        json
        math
        optional
        parser # deps on type_index
        pfr # use BOOST_USE_MODULES
        process # deps on type_index
        program_options # deps on any
        property_map # deps on any
        property_tree # deps on any
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

# ---- Add/prepare dependency handling via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

set(BOOST_SUBDIR boost_1_90_0)
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

set(BOOST_VERSION 1.90.0)
set(BOOST_URL
    "https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}-cmake.7z"
    CACHE STRING
    "Boost download URL"
)
set(BOOST_URL_SHA256
    "218e74c4aa362a994b7b7a23b2920f455a00205c656405fcf262cf60b8871921"
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
    PATCH_COMMAND
        git apply -p0
        ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/cmake-01.patch
    SYSTEM
    ${EXCLUDE_FROM_ALL}
)

FetchContent_GetProperties(Boost)
if(NOT Boost_POPULATED)
    message(STATUS "Fetching Boost")
    FetchContent_MakeAvailable(Boost)
    message(STATUS "Fetching Boost - done")
    set(BOOST_SOURCE ${boost_SOURCE_DIR})
    message(STATUS "Boost_SOURCE_DIR=${Boost_SOURCE_DIR}")
endif()

# if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION})
#     find_package(Patch REQUIRED)
#     message(STATUS "Patch found: ${Patch_EXECUTABLE}")
#     if(
#         EXISTS
#             ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/cmake-01.patch
#     )
#         message(STATUS "Patching Boost")
#         execute_process(
#             COMMAND
#                 ${Patch_EXECUTABLE} -N -p0 -i
#                 ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/cmake-01.patch
#             WORKING_DIRECTORY ${BOOST_SOURCE}
#             COMMAND_ECHO STDOUT
#         )
#         message(STATUS "Patching Boost - done")
#     endif()
# endif()

include(cmake/CheckBoostVersion.cmake)
message(STATUS "Boost found: ${BOOST_VERSION} ${BOOST_SOURCE}")

include(cmake/ccache.cmake)

configure_file(
    cmake/ccache.cmake
    ${BOOST_SOURCE}/tools/cmake/include/ccache.cmake
    COPYONLY
)

list(APPEND CMAKE_MODULE_PATH ${BOOST_SOURCE}/tools/cmake/include)
include(BoostTestJamfile OPTIONAL RESULT_VARIABLE HAVE_BOOST_TEST)
if(HAVE_BOOST_TEST)
    message(STATUS "We found boost ctest module: ${HAVE_BOOST_TEST}")
endif()

#############################################################
find_package(Threads)

# Compilation options required by all platforms
target_compile_definitions(
    boost_headers
    INTERFACE $<$<CONFIG:Release>:BOOST_DISABLE_ASSERT> BOOST_ASIO_NO_DEPRECATED
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

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(AddUninstallTarget)
