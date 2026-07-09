cmake_minimum_required(VERSION 3.30...4.4)

include(../cmake/enable-experimental-import-std.cmake)

# test boost-cmake v1.91.0-rc1
project(BoostExamples LANGUAGES CXX)

enable_testing()

# ---- Dependencies ----

if(PROJECT_IS_TOP_LEVEL)
    include(../cmake/ccache.cmake)

    find_package(magic_enum)

    set(CMAKE_SKIP_TEST_ALL_DEPENDENCY OFF)
    set(CMAKE_CXX_EXTENSIONS OFF)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
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
        if(CMAKE_CXX_STANDARD GREATER_EQUAL 23)
            set(CMAKE_CXX_MODULE_STD ON)
        else()
            set(CMAKE_CXX_MODULE_STD OFF)
        endif()
    else()
        set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
    endif()

    block()
        set(BOOST_DEBUG YES)
        set(BOOST_VERBOSE YES)
        list(APPEND BOOST_INCLUDE_LIBRARIES asio regex test)

        set(CMAKE_SKIP_INSTALL_RULES ON)

        set(BUILD_SHARED_LIBS OFF)
        set(BOOST_SKIP_INSTALL_RULES ${CMAKE_SKIP_INSTALL_RULES})
        set(BOOST_VERSION 1.91.0-1)

        include(FetchContent)
        FetchContent_Declare(
            Boost
            URL
                https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}-cmake.7z
            URL_HASH
                SHA256:29c7d4f4ac36ad853b6765d03571ea60d90286775df026b4efd9f3281131972b
            EXCLUDE_FROM_ALL
            SYSTEM
            FIND_PACKAGE_ARGS
                1.90.0.1
                COMPONENTS any asio regex unit_test_framework
        )
        FetchContent_MakeAvailable(Boost)
    endblock()
endif()

# ---- Create test binaries ----

if(PROJECT_IS_TOP_LEVEL AND TARGET magic_enum::magic_enum)
    add_executable(BitManipulation bit_manipulation.cpp)
    target_link_libraries(BitManipulation PRIVATE magic_enum::magic_enum)
    target_compile_definitions(BitManipulation PRIVATE USE_IMPORT_STD)
    target_compile_features(BitManipulation PRIVATE cxx_std_23)
    set_target_properties(BitManipulation PROPERTIES CXX_MODULE_STD ON)
    add_test(NAME BitManipulation COMMAND BitManipulation)
endif()

if(BOOST_USE_MODULES AND TARGET Boost::any)
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
            "-DCMAKE_CXX_MODULE_STD=${CMAKE_CXX_MODULE_STD}"
            "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}"
            "-DCMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON}"
            "-DCMAKE_BUILD_TYPE=$<CONFIG>"
            "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
            "-DBOOST_USE_MODULES=${BOOST_USE_MODULES}"
    )
endif()
