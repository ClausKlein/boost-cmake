function(_add_boost_lib)
  set(options)
  set(oneValueArgs NAME)
  set(multiValueArgs
      SOURCES
      LINK
      DEFINE
      DEFINE_PRIVATE
      CXXFLAGS_PRIVATE
      INCLUDE_PRIVATE
  )
  cmake_parse_arguments(
    BOOSTLIB
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  add_library(${BOOSTLIB_NAME} STATIC ${BOOSTLIB_SOURCES})
  add_library(Boost::${BOOSTLIB_NAME} ALIAS ${BOOSTLIB_NAME})
  set_target_properties(${BOOSTLIB_NAME} PROPERTIES OUTPUT_NAME "boost_${BOOSTLIB_NAME}" FOLDER "Boost")
  if(NOT BOOST_STANDALONE)
    set_target_properties(${BOOSTLIB_NAME} PROPERTIES EXCLUDE_FROM_ALL 1)
  endif()
  target_link_libraries(${BOOSTLIB_NAME} PUBLIC Boost::headers)
  if(MSVC)
    target_compile_options(${BOOSTLIB_NAME} PRIVATE /W0)
  elseif(NOT BOOST_USE_ALL_OPTIONAL_LIBS)
    target_compile_options(
      ${BOOSTLIB_NAME}
      PRIVATE # XXX -w
              -Wall
              -Wextra
              -Wpedantic
              -Werror
              -Wshadow
    )
  endif()
  if(BOOSTLIB_LINK)
    target_link_libraries(${BOOSTLIB_NAME} PUBLIC ${BOOSTLIB_LINK})
  endif()
  if(BOOSTLIB_DEFINE)
    target_compile_definitions(${BOOSTLIB_NAME} PUBLIC ${BOOSTLIB_DEFINE})
  endif()
  if(BOOSTLIB_DEFINE_PRIVATE)
    target_compile_definitions(${BOOSTLIB_NAME} PRIVATE ${BOOSTLIB_DEFINE_PRIVATE})
  endif()
  if(BOOSTLIB_CXXFLAGS_PRIVATE)
    target_compile_options(${BOOSTLIB_NAME} PRIVATE ${BOOSTLIB_CXXFLAGS_PRIVATE})
  endif()
  if(BOOSTLIB_INCLUDE_PRIVATE)
    target_include_directories(${BOOSTLIB_NAME} PRIVATE ${BOOSTLIB_INCLUDE_PRIVATE})
  endif()
endfunction()
