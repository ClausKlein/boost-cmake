# Detect Boost version

set(_BOOST_VERSION_FILE "${BOOST_SOURCE}/CMakeLists.txt")
if(NOT EXISTS ${_BOOST_VERSION_FILE})
    message(FATAL_ERROR "missing ${_BOOST_VERSION_FILE}")
endif()

file(STRINGS ${_BOOST_VERSION_FILE} boost_version_raw REGEX "Boost VERSION .*")
message(DEBUG "${boost_version_raw}")

string(REGEX MATCH "[0-9.]+" _BOOST_VERSION "${boost_version_raw}")
if(_BOOST_VERSION STREQUAL BOOST_VERSION)
    return()
endif()

message(FATAL_ERROR "Wrong Version ${_BOOST_VERSION} found!")
