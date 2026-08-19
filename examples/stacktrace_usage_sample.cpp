// Copyright Antony Polukhin, 2025-2026.
// Copyright Fedor Osetrov, 2025-2026.
//
// Distributed under the Boost Software License, Version 1.0. (See
// accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)

#include <boost/config.hpp>
#include <iostream>

#if defined(STACKTRACE_MODULE)
import STACKTRACE_MODULE;
#else
import boost.stacktrace;
#endif

namespace {

  BOOST_NOINLINE void foo() {
    auto trace = boost::stacktrace::stacktrace{};
    std::cerr << trace;
  }

  BOOST_NOINLINE void bar() {
    foo();
  }

}  // namespace

int main() {
  bar();

  return 0;
}
