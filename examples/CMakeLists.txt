cmake_minimum_required(VERSION 3.27...4.0)

project(BoostExamples LANGUAGES CXX)

enable_testing()

# ---- Dependencies ----

if(PROJECT_IS_TOP_LEVEL)
    set(CMAKE_SKIP_TEST_ALL_DEPENDENCY NO)
    if(NOT DEFINED CMAKE_CXX_STANDARD)
        set(CMAKE_CXX_STANDARD 17)
    endif()
    if(NOT DEFINED CMAKE_PREFIX_PATH)
        list(APPEND CMAKE_PREFIX_PATH ../stagedir)
    endif()
    include(../cmake/ccache.cmake)

    set(BOOST_DEBUG YES)
    set(BOOST_VERBOSE YES)
    list(APPEND BOOST_INCLUDE_LIBRARIES asio regex test)

    # TODO: use FETCHCONTENT with FIND_PACKAGE_ARGS!
    # XXX find_package(Boost 1.87 COMPONENTS asio regex unit_test_framework)
    # if(NOT Boost_FOUND)
    #     cpmaddpackage(
    #       NAME Boost-CMake
    #       GIT_TAG v1.87.0-rc5
    #       GITHUB_REPOSITORY "ClausKlein/boost-cmake"
    #     )
    # endif()

    set(CPM_USE_LOCAL_PACKAGES YES)
    include(../cmake/CPM.cmake)

    set(CMAKE_SKIP_INSTALL_RULES ON)
    set(CMAKE_INSTALL_MESSAGE LAZY)
    set(CMAKE_UNITY_BUILD ON)

    set(BOOST_VERSION 1.87.0)
    set(BUILD_SHARED_LIBS ON)

    cpmaddpackage(
      NAME Boost
      VERSION ${BOOST_VERSION}
      URL https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}-cmake.tar.xz
      URL_HASH SHA256=7da75f171837577a52bbf217e17f8ea576c7c246e4594d617bfde7fafd408be5
      EXCLUDE_FROM_ALL ON
      SYSTEM ON
      OPTIONS "BOOST_ENABLE_CMAKE ON" "BOOST_SKIP_INSTALL_RULES ${CMAKE_SKIP_INSTALL_RULES}"
      FIND_PACKAGE_ARGUMENTS "COMPONENTS asio\\\;regex\\\;unit_test_framework"
    )
endif()

# ---- Create test binaries ----

add_executable(ExampleAsio deferred.cpp)
# XXX target_compile_features(ExampleAsio PRIVATE cxx_std_17)

add_executable(ExampleRegex regex.cpp)
# XXX target_compile_features(ExampleRegex PRIVATE cxx_std_17)

target_link_libraries(ExampleAsio PRIVATE Boost::asio)
target_link_libraries(ExampleRegex PRIVATE Boost::regex)

if(Boost_FOUND OR TARGET Boost::unit_test_framework)
    add_executable(ExampleTest const_string_test.cpp)
    # XXX target_compile_features(ExampleTest PRIVATE cxx_std_17)
    target_link_libraries(ExampleTest PRIVATE Boost::unit_test_framework)
    add_test(NAME ExampleTest COMMAND ExampleTest)
endif()

# ---- Testing ----

add_test(NAME ExampleAsio COMMAND ExampleAsio)
add_test(NAME ExampleRegex COMMAND ExampleRegex)

# test if the targets are findable from the build directory
if(NOT PROJECT_IS_TOP_LEVEL)
    add_test(
        NAME find-package-test
        COMMAND
            ${CMAKE_CTEST_COMMAND}
            # --verbose
            --output-on-failure -C $<CONFIG> --build-and-test
            "${CMAKE_CURRENT_SOURCE_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}/find-package-test" --build-generator
            ${CMAKE_GENERATOR} --build-makeprogram ${CMAKE_MAKE_PROGRAM}
            --build-options "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
            "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}"
            "-DCMAKE_BUILD_TYPE=$<CONFIG>"
            "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
    )
endif()
