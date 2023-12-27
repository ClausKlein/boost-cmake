cmake_minimum_required(VERSION 3.21...3.28)

project(Boost-CMake LANGUAGES C CXX VERSION 1.81.0.1)

if(PROJECT_IS_TOP_LEVEL)
  message(STATUS "PROJECT_IS_TOP_LEVEL")
else()
  option(BOOST_DISABLE_TESTS "Do not build test targets, even if building standalone" ON)
endif()

# ---- Add/prepare dependency handling via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

set(BOOST_SUBDIR boost_1_81_0)
if(EXISTS "$ENV{CPM_SOURCE_CACHE}/${BOOST_SUBDIR}")
  set(FETCHCONTENT_SOURCE_DIR_BOOST "$ENV{CPM_SOURCE_CACHE}/${BOOST_SUBDIR}" CACHE PATH "Boost source DIR")
  set(CPM_Boost_SOURCE ${FETCHCONTENT_SOURCE_DIR_BOOST} CACHE PATH "Manual override")
endif()

set(BOOST_VERSION 1.81.0)
set(BOOST_URL "https://boostorg.jfrog.io/artifactory/main/release/${BOOST_VERSION}/source/${BOOST_SUBDIR}.tar.bz2"
    CACHE STRING "Boost download URL"
)
set(BOOST_URL_SHA256 "71feeed900fbccca04a3b4f2f84a7c217186f28a940ed8b7ed4725986baf99fa"
    CACHE STRING "Boost download URL SHA256 checksum"
)

# ---- Add Boost source tar archive via FetchContent ----
include(FetchContent)
FetchContent_Declare(Boost URL ${BOOST_URL} URL_HASH SHA256=${BOOST_URL_SHA256})

FetchContent_GetProperties(Boost)
if(NOT Boost_POPULATED)
  message(STATUS "Fetching Boost")
  FetchContent_Populate(Boost)
  message(STATUS "Fetching Boost - done")
  set(BOOST_SOURCE ${boost_SOURCE_DIR})

  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION})
    find_package(Patch)
    if(Patch_FOUND)
      message("Patch found: ${Patch_EXECUTABLE}")
      message("Patching Boost")
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/archive-01.patch)
        execute_process(
          COMMAND ${Patch_EXECUTABLE} -N -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/archive-01.patch
          WORKING_DIRECTORY ${BOOST_SOURCE}/boost/archive COMMAND_ECHO STDOUT
        )
      endif()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/thread_future-01.patch)
        execute_process(
          COMMAND ${Patch_EXECUTABLE} -N -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/thread_future-01.patch
          WORKING_DIRECTORY ${BOOST_SOURCE}/boost COMMAND_ECHO STDOUT
        )
      endif()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/serialization-01.patch)
        execute_process(
          COMMAND ${Patch_EXECUTABLE} -N -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/serialization-01.patch
          WORKING_DIRECTORY ${BOOST_SOURCE}/libs/serialization COMMAND_ECHO STDOUT
        )
      endif()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/filesystem-01.patch)
        execute_process(
          COMMAND ${Patch_EXECUTABLE} -N -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/filesystem-01.patch
          WORKING_DIRECTORY ${BOOST_SOURCE}/libs/filesystem COMMAND_ECHO STDOUT
        )
      endif()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/date_time-01.patch)
        execute_process(
          COMMAND ${Patch_EXECUTABLE} -N -p2 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/date_time-01.patch
          WORKING_DIRECTORY ${BOOST_SOURCE} COMMAND_ECHO STDOUT
        )
      endif()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/date_time-02.patch)
        execute_process(
          COMMAND ${Patch_EXECUTABLE} -N -R -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/${BOOST_VERSION}/date_time-02.patch
          WORKING_DIRECTORY ${BOOST_SOURCE}/libs/date_time COMMAND_ECHO STDOUT
        )
      endif()
      message("Patching Boost - done")
    endif()
  endif()

endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

include(CheckBoostVersion)
message(STATUS "Boost found: ${BOOST_VERSION} ${BOOST_SOURCE}")

include(StandaloneBuild)
include(PlatformDetect)
include(AddBoostLib)
include(AddBoostTest)

# NOTE: Install the missing CMakeList.txt file, but it will not yet used! CK
#       If the tar archive contains one, it will not overridden.
configure_file(cmake/CMakeLists.txt.in ${BOOST_SOURCE}/CMakeLists.txt @ONLY)
configure_file(cmake/Modules/ccache.cmake ${BOOST_SOURCE}/tools/cmake/include/ccache.cmake COPYONLY)

# NOTE: Use the FOLDER target property to organize targets into folders.
set_property(GLOBAL PROPERTY USE_FOLDERS TRUE)

# ensure that the debug and release builds use different names for the libraries that will be installed.
set(CMAKE_DEBUG_POSTFIX -d)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

if(USE_ANDROID)
  # CMake 3.7.1 doesn't define the target triple for the ASM language,
  # resulting in all files compiled for the host architecture
  set(CMAKE_ASM_COMPILER_TARGET "${CMAKE_CXX_COMPILER_TARGET}")
endif()

set(BOOST_LIBS_REQUIRED header)
if(PROJECT_IS_TOP_LEVEL)
  # Compiled libs without warnings OSX with clang v17.0.6
  list(APPEND
       BOOST_INCLUDE_LIBRARIES
       atomic
       chrono
       exception
       filesystem
       math
       regex
       serialization
       system
       thread
       timer
  )
endif()

set(BOOST_LIBS_OPTIONAL
    atomic
    chrono
    container # warnings
    context
    coroutine # depends on test
    date_time
    exception
    fiber # warnings
    filesystem
    graph # warnings
    iostreams # depends on test
    json # depends on container
    # FIXME: locale  # NOTE: to complex, refactory needed!
    # TODO(CK) log   # errors
    math
    mpi # warnings
    graph_parallel # TODO(CK): depends on graph; does this really depends on mpi?
    program_options
    # XXX python # NOTE: not supported, to complex module!
    random # warnings
    regex
    serialization
    system
    test # warnings
    thread
    timer
    type_erasure
    wave
    CACHE STRING "Boost libs to be compiled"
)

foreach(lib IN LISTS BOOST_LIBS_REQUIRED)
  include("libs/${lib}.cmake")
endforeach()

#############################################################
# TODO(CK): Move this to libs/header.cmake in the right file
find_package(Threads)

# Compilation options required by all platforms
target_compile_definitions(
  boost
  INTERFACE $<$<CONFIG:Release>:BOOST_DISABLE_ASSERT>
            BOOST_ASIO_NO_DEPRECATED
            BOOST_THREAD_VERSION=5
            BOOST_THREAD_USES_CHRONO
            BOOST_THREAD_PROVIDES_EXECUTORS
)
target_link_libraries(boost INTERFACE Threads::Threads)
target_compile_definitions(boost INTERFACE BOOST_BIND_GLOBAL_PLACEHOLDERS)
add_library(Boost::boost ALIAS boost)
#############################################################

list(APPEND BOOST_INCLUDE_LIBRARIES asio)
list(APPEND BOOST_INCLUDE_LIBRARIES headers)
list(REMOVE_DUPLICATES BOOST_INCLUDE_LIBRARIES)

foreach(lib IN LISTS BOOST_INCLUDE_LIBRARIES)
  # In case only a subset of modules is available
  if(EXISTS "${BOOST_SOURCE}/libs/${lib}" AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/libs/${lib}.cmake")
    message(STATUS "include(libs/${lib}.cmake)")
    include("libs/${lib}.cmake")
  else()
    message(STATUS "add_library(${lib} INTERFACE)")
    add_library(${lib} INTERFACE)
    target_link_libraries(${lib} INTERFACE Boost::boost)
  endif()
endforeach()

if(UNIX)
  # TODO(CK): too many deprecated warnings!
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(boost INTERFACE -Wno-deprecated-copy)
  endif()
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION GREATER_EQUAL 10.0)
    target_compile_options(
      boost INTERFACE -Wno-deprecated-copy-dtor -Wno-newline-eof -Wno-deprecated-copy-with-user-provided-copy
    )
  endif()
  if(USE_APPLE)
    target_compile_options(boost INTERFACE -Wno-deprecated-declarations)
  endif()
endif()

if(USE_ANDROID)
  # Android doesn't support thread local storage through compiler intrinsics
  target_compile_definitions(boost INTERFACE BOOST_ASIO_DISABLE_THREAD_KEYWORD_EXTENSION)
endif()

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

# ---- Install rules ----

# PackageProject.cmake will be used to make our target installable

if(BOOST_USE_ORIGINAL_PackageProject)
  include(cmake/CPM.cmake)
  CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.11.0")

  set(BOOST_LIBS ${BOOST_LIBS_OPTIONAL})
  list(REMOVE_ITEM BOOST_LIBS test)
  list(APPEND BOOST_LIBS unit_test_framework)
  if(NOT TARGET mpi)
    list(REMOVE_ITEM BOOST_LIBS graph_parallel)
  endif()
  if(NOT MPI_CXX_FOUND)
    list(REMOVE_ITEM BOOST_LIBS mpi)
  endif()

  if(ICONV_FOUND)
    install(TARGETS boost_locale_deps EXPORT boostTargets)
  else()
    list(REMOVE_ITEM BOOST_LIBS locale)
  endif()

  list(REMOVE_DUPLICATES BOOST_LIBS)
  install(TARGETS ${BOOST_LIBS} EXPORT boostTargets)
else()
  include(cmake/PackageProject.cmake)

  set(BOOST_LIBS ${BOOST_INCLUDE_LIBRARIES})
  list(APPEND BOOST_LIBS boost)
endif()

packageProject(
  NAME Boost
  TARGETS ${BOOST_LIBS}
  VERSION ${BOOST_VERSION}
  NAMESPACE Boost
  BINARY_DIR ${PROJECT_BINARY_DIR}
  ARCH_INDEPENDENT NO
  INCLUDE_DIR ${BOOST_SOURCE}/boost
  INCLUDE_DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/boost
  INCLUDE_HEADER_REGEX [=[.*\.(inc|h|hpp|ipp)$]=]
  DISABLE_VERSION_SUFFIX YES
  COMPATIBILITY SameMajorVersion
  DEPENDENCIES "Threads" # TODO(CK): variable list needed for: BZIP2; Iconf; ICU; MPI; ZLIB
  CPACK NO
)

include(AddUninstallTarget)
include(CPack)
