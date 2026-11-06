// Copyright (c) 2024-2025 Antony Polukhin
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

// To compile manually use a command like the following:
// clang++ -std=c++20 -fmodule-file=lexical_cast.pcm lexical_cast.pcm usage_sample.cpp

//[lexical_cast_module_example
#ifndef BOOST_LEXICAL_CAST_USE_STD_MODULE
#  include <typeinfo>  // XXX to prevent g++-16 error: must ‘#include <typeinfo>’ before using ‘typeid’
#endif

import boost.lexical_cast;

auto main() -> int {
  return boost::lexical_cast<int>("0");
}
//]
