cmake_minimum_required(VERSION 3.28...3.31)

project(BoostExamples)

# ---- Create binary ----

add_executable(ExampleAsio deferred.cpp)
target_compile_features(ExampleAsio PRIVATE cxx_std_17)

add_executable(ExampleRegex regex.cpp)
target_compile_features(ExampleRegex PRIVATE cxx_std_17)

# XXX add_executable(ExampleTest const_string_test.cpp)
# XXX target_compile_features(ExampleTest PRIVATE cxx_std_17)

# ---- Dependencies ----

option(TEST_INSTALLED_VERSION "Test installed version" ${PROJECT_IS_TOP_LEVEL})
if(TEST_INSTALLED_VERSION)
    set(CMAKE_SKIP_TEST_ALL_DEPENDENCY NO)
    set(CPM_USE_LOCAL_PACKAGES YES)
    include(../cmake/CPM.cmake)

    list(APPEND BOOST_INCLUDE_LIBRARIES asio regex test)
    cpmaddpackage(
      NAME Boost
      VERSION 1.87.0
      GIT_TAG feature/bump-to-boost-v1.87.0
      # TODO: v1.87.0-rc1
      GITHUB_REPOSITORY "ClausKlein/boost-cmake"
    )
endif()

target_link_libraries(ExampleAsio PRIVATE Boost::asio)
target_link_libraries(ExampleRegex PRIVATE Boost::regex)
# XXX target_link_libraries(ExampleTest PRIVATE Boost::unit_test_framework)

# ---- Testing ----

enable_testing()

add_test(NAME ExampleAsio COMMAND ExampleAsio)
add_test(NAME ExampleRegex COMMAND ExampleRegex)
# XXX add_test(NAME ExampleTest COMMAND ExampleTest)
