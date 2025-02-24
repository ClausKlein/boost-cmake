if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
endif()

if(PROJECT_IS_TOP_LEVEL)
    message(STATUS "Standalone mode detected")
    set(BOOST_STANDALONE ON)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
    enable_testing()

    include(ccache)
endif()
