# Define the header-only Boost targets
add_library(boost INTERFACE)
add_library(Boost::headers ALIAS boost)

include(GNUInstallDirs)

target_include_directories(
    boost
    INTERFACE
        $<BUILD_INTERFACE:${BOOST_SOURCE}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_compile_features(boost INTERFACE cxx_std_${CMAKE_CXX_STANDARD})

# Disable autolink
target_compile_definitions(boost INTERFACE BOOST_ALL_NO_LIB=1)
