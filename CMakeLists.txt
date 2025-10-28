cmake_minimum_required(VERSION 3.25...4.4)

project(Boost-CMake LANGUAGES CXX VERSION 1.87.0.5)

if(PROJECT_IS_TOP_LEVEL)
    option(BOOST_BUILD_ALL "Do build all targets" OFF)
    option(BUILD_TESTING "Do build all tests" ON)
endif()

option(
    BUILD_SHARED_LIBS
    "A standard CMake variable that determines whether to build shared or static libraries. Defaults to ON"
    ON
)

if(UNIX)
    message(STATUS "Use CMAKE_UNITY_BUILD")
    set(CMAKE_UNITY_BUILD ON)
endif()

set(CMAKE_INSTALL_MESSAGE LAZY)
set(CMAKE_SKIP_TEST_ALL_DEPENDENCY OFF)

if(CMAKE_SKIP_INSTALL_RULES)
    set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY ON)
    set(EXCLUDE_FROM_ALL EXCLUDE_FROM_ALL)
else()
    set(EXCLUDE_FROM_ALL)
    set(BOOST_SKIP_INSTALL_RULES OFF)
endif()

# NOTE: Use the FOLDER target property to organize targets into folders.
set_property(GLOBAL PROPERTY USE_FOLDERS TRUE)

# ensure that the debug and release builds use different names for the libraries that will be installed.
set(CMAKE_DEBUG_POSTFIX -d)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
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
        beast
        chrono
        exception
        filesystem
        program_options
        regex
        signals2
        system
        thread
        test
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
endif()

include(cmake/CheckBoostVersion.cmake)
message(STATUS "Boost found: ${BOOST_VERSION} ${BOOST_SOURCE}")

include(cmake/ccache.cmake)

configure_file(
    cmake/ccache.cmake
    ${BOOST_SOURCE}/tools/cmake/include/ccache.cmake
    COPYONLY
)

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

include(CPack)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(AddUninstallTarget)
