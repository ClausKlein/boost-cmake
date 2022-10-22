# Boost CMake [![CMake](https://github.com/ClausKlein/boost-cmake/actions/workflows/cmake.yml/badge.svg)](https://github.com/ClausKlein/boost-cmake/actions/workflows/cmake.yml)

## Synopsis

Easy Boost integration in CMake projects!

Only the boost libraries and their dependencies you link to your targets are build!

## Code Example

Add it to your project with [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake)
in your CMakeLists.txt file:

```
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)

# to get CMAKE_INSTALL_INCLUDEDIR
include(GNUInstallDirs)

include(cmake/CPM.cmake)

# PackageProject.cmake will be used to make our target installable
CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.9.0")

option(BUILD_SHARED_LIBS "Build shared libraries" NO)
CPMAddPackage("gh:ClausKlein/boost-cmake@1.79.3")

target_include_directories(
  ${PROJECT_NAME} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                         $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
...

target_link_libraries(lib_using_filesystem PUBLIC Boost::filesystem)
target_link_libraries(lib_using_header_only PUBLIC Boost::boost)
```

## Configuration

Boost will automatically be downloaded from https://boostorg.jfrog.io/artifactory/main/release !

If that is not acceptable to you, you can use an alternate Boost version, apply
custom patches or just mirror the current archive in your internal network like so:
```
set(BOOST_URL http://internal.mirror/boost.7z)
set(BOOST_URL_SHA256 foobar)
```

If you have Boost sources already available and want to point to them, you can use the following:
```
set(FETCHCONTENT_SOURCE_DIR_BOOST /path/to/boost)
add_subdirectory(boost-cmake)
```

For more advanced configuration, you may want to install your project depending on boost libraries
using [PackageProject](https://github.com/TheLartians/PackageProject.cmake) i.e.:
```
if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

install(TARGETS filesystem serialization EXPORT boostTargets)

packageProject(
  NAME ${PROJECT_NAME}
  VERSION ${PROJECT_VERSION}
  NAMESPACE ${PROJECT_NAME}
  BINARY_DIR ${PROJECT_BINARY_DIR}
  INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include
  INCLUDE_DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
  INCLUDE_HEADER_PATTERN "*.h"
  DISABLE_VERSION_SUFFIX YES
  COMPATIBILITY SameMajorVersion
  DEPENDENCIES "Boost 1.79"
)

include(CPack)
```

## Motivation

Most people struggle building Boost for various platforms or using package managers to get the right version, so I figured I would open-source the solution similar to the one I developed while I worked at Spotify.

Using this, as long as your main project is configured properly, Boost will be built with the same compiler, same architectures (in case of universal macOS or iOS build), same compilation flags (think of Clang sanitizers for example) without any hassle.

The Boost sources will be automatically downloaded from CMake if they cannot be found. You can also fork the project and add the boost source package if you wish to do so, or use an alternative URL pointing for example to an HTTP cache internal to your network.

## Contributors

Not all libraries are currently built. Patches accepted to build the remaining ones!

## License

BSD 3-clause license. See LICENSE.md file.
