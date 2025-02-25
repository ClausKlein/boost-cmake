# Detect Boost version

set(_BOOST_VERSION_FILE "${BOOST_SOURCE}/libs/config/include/boost/version.hpp")
if(NOT EXISTS ${_BOOST_VERSION_FILE})
    message(FATAL_ERROR "missing ${_BOOST_VERSION_FILE}")
endif()

file(
    STRINGS
    ${_BOOST_VERSION_FILE}
    boost_version_raw
    REGEX "define BOOST_VERSION "
)
string(REGEX MATCH "[0-9]+" boost_version_raw "${boost_version_raw}")
math(EXPR BOOST_VERSION_MAJOR "${boost_version_raw} / 100000")
math(EXPR BOOST_VERSION_MINOR "${boost_version_raw} / 100 % 1000")
math(EXPR BOOST_VERSION_PATCH "${boost_version_raw} % 100")
set(_BOOST_VERSION
    "${BOOST_VERSION_MAJOR}.${BOOST_VERSION_MINOR}.${BOOST_VERSION_PATCH}"
)

if(_BOOST_VERSION STREQUAL BOOST_VERSION)
    return()
endif()

message(FATAL_ERROR "Wrong Version ${_BOOST_VERSION} found!")
