cmake_minimum_required(VERSION 3.30...4.4)

include(../cmake/prelude.cmake)

# test boost-cmake 1.92.0.3
project(BoostExamples LANGUAGES CXX)

enable_testing()

# ---- Dependencies ----

if(PROJECT_IS_TOP_LEVEL)
    include(../cmake/ccache.cmake)

    # NO! find_package(magic_enum)

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
        if(NOT CMAKE_CXX_STANDARD GREATER_EQUAL 23)
            set(CMAKE_CXX_MODULE_STD OFF)
        endif()
    else()
        set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
    endif()

    block()
        set(BOOST_DEBUG YES)
        set(BOOST_VERBOSE YES)
        list(
            APPEND BOOST_INCLUDE_LIBRARIES
            any
            asio
            conversion
            lexical_cast
            pfr
            regex
            type_index
            stacktrace
            test
        )

        set(CMAKE_SKIP_INSTALL_RULES ON)

        set(BUILD_SHARED_LIBS OFF)
        set(BOOST_SKIP_INSTALL_RULES ${CMAKE_SKIP_INSTALL_RULES})
        set(BOOST_VERSION 1.92.0)

        include(FetchContent)
        FetchContent_Declare(
            Boost
            URL
                https://github.com/boostorg/boost/releases/download/boost-${BOOST_VERSION}/boost-${BOOST_VERSION}-cmake.7z
            URL_HASH SHA256=158852d45a7ce23de167a3dc2e57b04490829b233f06e835d5c81a65547ef68b
            EXCLUDE_FROM_ALL
            SYSTEM
            FIND_PACKAGE_ARGS
                ${BOOST_VERSION}
                COMPONENTS
                    any
                    asio
                    conversion
                    lexical_cast
                    pfr
                    regex
                    type_index
                    stacktrace
                    unit_test_framework
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

function(boost_library_uses_modules boost_target result_variable)
    if(NOT TARGET "${boost_target}")
        set("${result_variable}" FALSE PARENT_SCOPE)
        return()
    endif()

    get_target_property(
        interface_compile_definitions
        "${boost_target}"
        INTERFACE_COMPILE_DEFINITIONS
    )

    # NOTE: quotes needed here! CK
    if("BOOST_USE_MODULES" IN_LIST interface_compile_definitions)
        set("${result_variable}" TRUE PARENT_SCOPE)
        message(STATUS "${boost_target} uses C++ modules")
    else()
        set("${result_variable}" FALSE PARENT_SCOPE)
        message(WARNING "${boost_target} has no C++ modules")
    endif()
endfunction()

function(add_boost_module_example example_name boost_target source_file)
    if(NOT TARGET "${boost_target}")
        message(WARNING "${boost_target} not found!")
        return()
    endif()

    boost_library_uses_modules("${boost_target}" __uses_modules)
    if(__uses_modules)
        add_executable("${example_name}" "${source_file}")
        target_link_libraries("${example_name}" PRIVATE "${boost_target}")
        add_test(NAME "${example_name}" COMMAND "${example_name}")
    endif()
endfunction()

function(add_boost_example example_name boost_target source_file)
    if(NOT TARGET "${boost_target}")
        return()
    endif()

    add_executable("${example_name}" "${source_file}")
    target_link_libraries("${example_name}" PRIVATE "${boost_target}")
    add_test(NAME "${example_name}" COMMAND "${example_name}")
endfunction()

add_boost_module_example(ExampleAny Boost::any any_module_usage_sample.cpp)
add_boost_module_example(ExampleConversion Boost::conversion conversion_usage_sample.cpp)
add_boost_module_example(ExampleLexical_cast Boost::lexical_cast lexical_cast_usage_sample.cpp)
add_boost_module_example(ExampleStacktrace Boost::stacktrace stacktrace_usage_sample.cpp)
add_boost_module_example(ExampleType_index Boost::type_index type_index_usage_sample.cpp)
if(APPLE)
    # TODO(CK): why only on Darwin? Check this!
    add_boost_module_example(ExamplePfr Boost::pfr pfr_usage_sample.cpp)
endif()

add_boost_example(ExampleAsio Boost::asio asio_deferred.cpp)
add_boost_example(ExampleRegex Boost::regex regex.cpp)

if(APPLE)
    add_boost_example(ExampleUnit_test_framework Boost::unit_test_framework const_string_test.cpp)
endif()

# ---- Testing ----

# test if the targets are findable from the build directory
if(NOT PROJECT_IS_TOP_LEVEL)
    add_test(
        NAME find-package-test
        COMMAND
            ${CMAKE_CTEST_COMMAND} --output-on-failure -C $<CONFIG> #
            --build-and-test "${CMAKE_CURRENT_SOURCE_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}/find-package-test" #
            --build-generator "${CMAKE_GENERATOR}" #
            --build-makeprogram "${CMAKE_MAKE_PROGRAM}" #
            --build-options "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
            "-DCMAKE_CXX_MODULE_STD=${CMAKE_CXX_MODULE_STD}"
            "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}"
            "-DCMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON}"
            "-DCMAKE_BUILD_TYPE=$<CONFIG>" "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
            "-DBOOST_USE_MODULES=${BOOST_USE_MODULES}"
    )
endif()
