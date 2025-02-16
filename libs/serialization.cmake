

if(USE_WINDOWS)
  set(SERIALIZATION_WIN_SRCS
    ${BOOST_SOURCE}/libs/serialization/src/basic_text_wiprimitive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_text_woprimitive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/text_wiarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/text_woarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/xml_wgrammar.cpp
    ${BOOST_SOURCE}/libs/serialization/src/xml_wiarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/xml_woarchive.cpp
  )
  set(CXXFLAGS "/Gy")
endif()

_add_boost_lib(
  NAME serialization
  SOURCES
    ${SERIALIZATION_WIN_SRCS}
    ${BOOST_SOURCE}/libs/serialization/src/archive_exception.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_archive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_iarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_iserializer.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_oarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_oserializer.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_pointer_iserializer.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_pointer_oserializer.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_serializer_map.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_text_iprimitive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_text_oprimitive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_xml_archive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/basic_xml_grammar.ipp
    ${BOOST_SOURCE}/libs/serialization/src/binary_iarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/binary_oarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/binary_wiarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/binary_woarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/codecvt_null.cpp
    ${BOOST_SOURCE}/libs/serialization/src/extended_type_info.cpp
    ${BOOST_SOURCE}/libs/serialization/src/extended_type_info_no_rtti.cpp
    ${BOOST_SOURCE}/libs/serialization/src/extended_type_info_typeid.cpp
    ${BOOST_SOURCE}/libs/serialization/src/polymorphic_iarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/polymorphic_oarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/stl_port.cpp
    ${BOOST_SOURCE}/libs/serialization/src/text_iarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/text_oarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/utf8_codecvt_facet.cpp
    ${BOOST_SOURCE}/libs/serialization/src/void_cast.cpp
    ${BOOST_SOURCE}/libs/serialization/src/xml_archive_exception.cpp
    ${BOOST_SOURCE}/libs/serialization/src/xml_grammar.cpp
    ${BOOST_SOURCE}/libs/serialization/src/xml_iarchive.cpp
    ${BOOST_SOURCE}/libs/serialization/src/xml_oarchive.cpp
  CXXFLAGS_PRIVATE
    $<$<CXX_COMPILER_ID:MSVC>:/Gy>
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-fvisibility=hidden -fvisibility-inlines-hidden -ftemplate-depth-255>
)

_add_boost_lib(
  NAME serialization_test_A
  SOURCES
    ${BOOST_SOURCE}/libs/serialization/test/A.cpp
)

_add_boost_test(
  NAME serialization_test
  LINK
    Boost::serialization_test_A
    Boost::serialization
    Boost::filesystem
  # TODO(CK): DEFINE
    # BOOST_HAS_HASH
    # BOOST_HAS_SLIST
  TESTS
    # RUN ${BOOST_SOURCE}/libs/serialization/test/test_map_hashed.cpp
    # RUN ${BOOST_SOURCE}/libs/serialization/test/test_set_hashed.cpp
    # RUN ${BOOST_SOURCE}/libs/serialization/test/test_slist.cpp
    # RUN ${BOOST_SOURCE}/libs/serialization/test/test_slist_ptrs.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_array.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_binary.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_bitset.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_boost_array.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_complex.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_contained_class.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_cyclic_ptrs.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_deque.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_derived_class.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_derived_class_ptr.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_diamond.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_diamond_complex.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_forward_list.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_forward_list_ptrs.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_list.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_list_ptrs.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_map.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_map_boost_unordered.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_map_unordered.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_multiple_ptrs.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_native_array.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_new_operator.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_nvp.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_object.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_optional.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_priority_queue.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_queue.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_recursion.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_set.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_set_boost_unordered.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_set_unordered.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_shared_ptr.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_simple_class.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_simple_class_ptr.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_stack.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_unique_ptr.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_variant.cpp
    RUN ${BOOST_SOURCE}/libs/serialization/test/test_vector.cpp
)
