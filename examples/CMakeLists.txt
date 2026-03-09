cmake_minimum_required(VERSION 3.30...4.3)

project(BoostExamples LANGUAGES CXX)

enable_testing()

# ---- Dependencies ----

if(PROJECT_IS_TOP_LEVEL)
    include(../cmake/ccache.cmake)

    set(CMAKE_SKIP_TEST_ALL_DEPENDENCY NO)
    if(NOT DEFINED CMAKE_CXX_STANDARD)
        set(CMAKE_CXX_STANDARD 20)
    endif()
    if(NOT DEFINED CMAKE_PREFIX_PATH)
        list(APPEND CMAKE_PREFIX_PATH ../stagedir)
    endif()
    if(NOT DEFINED BOOST_USE_MODULES)
        set(BOOST_USE_MODULES OFF)
    endif()
    if(BOOST_USE_MODULES)
        set(CMAKE_CXX_SCAN_FOR_MODULES ON)
        set(CMAKE_CXX_MODULE_STD OFF) # TODO(CK): not yet!
    else()
        set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
    endif()

    block()
        set(BOOST_DEBUG YES)
        set(BOOST_VERBOSE YES)
        list(APPEND BOOST_INCLUDE_LIBRARIES any asio regex test)

        set(CMAKE_SKIP_INSTALL_RULES ON)

        set(BUILD_SHARED_LIBS ON)
        set(BOOST_SKIP_INSTALL_RULES ${CMAKE_SKIP_INSTALL_RULES})
        set(BOOST_VERSION 1.90.0)

        include(FetchContent)
        FetchContent_Declare(
            Boost
            URL
                https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}-cmake.7z
            URL_HASH
                SHA256=218e74c4aa362a994b7b7a23b2920f455a00205c656405fcf262cf60b8871921
            EXCLUDE_FROM_ALL
            SYSTEM
            FIND_PACKAGE_ARGS
                ${BOOST_VERSION}
                COMPONENTS
                any
                asio
                regex
                unit_test_framework
        )
        FetchContent_MakeAvailable(Boost)
    endblock()
endif()

# ---- Create test binaries ----

if(BOOST_USE_MODULES)
    add_executable(ExampleModuleAny any_module_usage_sample.cpp)
    target_link_libraries(ExampleModuleAny PRIVATE Boost::any)
    add_test(NAME ExampleModuleAny COMMAND ExampleModuleAny)
endif()

add_executable(ExampleAsio deferred.cpp)
target_link_libraries(ExampleAsio PRIVATE Boost::asio)

add_executable(ExampleRegex regex.cpp)
target_link_libraries(ExampleRegex PRIVATE Boost::regex)

if(TARGET Boost::unit_test_framework)
    add_executable(ExampleTest const_string_test.cpp)
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
            "-DBOOST_USE_MODULES=${BOOST_USE_MODULES}"
    )
endif()
