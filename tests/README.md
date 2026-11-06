## Minimal reproducible example for this build problem of `boost::lexical_cast`:

Same result on Linux with gcc (GCC) 16.1.1 20260713 and, OSX with (Homebrew GCC 16.1.0)

### usage:

```bash
cmake -S . -B build -G Ninja \
    -D CMAKE_CXX_COMPILER=g++-16 \
    -D CMAKE_CXX_COMPILER_LAUNCHER=

cmake --build build --verbose
```

```bash
root@23cd2d07fb08:/src# cmake --build --preset Release
[0/2] Re-checking globbed directories...
[7/20] Building CXX object examples/CMakeFiles/ExampleLexical_cast.dir/lexical_cast_usage_sample.cpp.o
FAILED: [code=1] examples/CMakeFiles/ExampleLexical_cast.dir/lexical_cast_usage_sample.cpp.o
/usr/bin/ccache /usr/bin/g++ -DBOOST_CONTAINER_NO_LIB -DBOOST_USE_MODULES -isystem /src/build/Release/_deps/boost-src/libs/lexical_cast/include -isystem /src/build/Release/_deps/boost-src/libs/config/include -isystem /src/build/Release/_deps/boost-src/libs/container/include -isystem /src/build/Release/_deps/boost-src/libs/assert/include -isystem /src/build/Release/_deps/boost-src/libs/intrusive/include -isystem /src/build/Release/_deps/boost-src/libs/move/include -isystem /src/build/Release/_deps/boost-src/libs/core/include -isystem /src/build/Release/_deps/boost-src/libs/throw_exception/include -O3 -DNDEBUG -std=c++23 -MD -MT examples/CMakeFiles/ExampleLexical_cast.dir/lexical_cast_usage_sample.cpp.o -MF examples/CMakeFiles/ExampleLexical_cast.dir/lexical_cast_usage_sample.cpp.o.d -fmodules-ts -fmodule-mapper=examples/CMakeFiles/ExampleLexical_cast.dir/lexical_cast_usage_sample.cpp.o.modmap -MD -fdeps-format=p1689r5 -x c++ -o examples/CMakeFiles/ExampleLexical_cast.dir/lexical_cast_usage_sample.cpp.o -c /src/examples/lexical_cast_usage_sample.cpp
In file included from /src/build/Release/_deps/boost-src/libs/lexical_cast/include/boost/lexical_cast.hpp:38,
                 from /src/build/Release/_deps/boost-src/libs/lexical_cast/modules/boost_lexical_cast.cppm:57,
of module boost.lexical_cast, imported at /src/examples/lexical_cast_usage_sample.cpp:12:
/src/build/Release/_deps/boost-src/libs/lexical_cast/include/boost/lexical_cast/bad_lexical_cast.hpp: In instantiation of ‘void boost::conversion::detail::throw_bad_cast@boost.lexical_cast() [with S = char [2]; T = int]’:
/src/build/Release/_deps/boost-src/libs/lexical_cast/include/boost/lexical_cast.hpp:50:70:   required from ‘Target boost::lexical_cast@boost.lexical_cast(const Source&) [with Target = int; Source = char [2]]’
   50 |             boost::conversion::detail::throw_bad_cast<Source, Target>();
      |             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~
/src/examples/lexical_cast_usage_sample.cpp:16:34:   required from here
   16 |   return boost::lexical_cast<int>("0");
      |          ~~~~~~~~~~~~~~~~~~~~~~~~^~~~~
/src/build/Release/_deps/boost-src/libs/lexical_cast/include/boost/lexical_cast/bad_lexical_cast.hpp:96:45: error: must ‘#include <typeinfo>’ before using ‘typeid’
   39 |     // exception used to indicate runtime lexical_cast failure
  +++ |+#include <typeinfo>
   40 |     class BOOST_SYMBOL_VISIBLE bad_lexical_cast :
......
   96 |         const std::type_info& source_type = typeid(S);
      |                                             ^~~~~~~~~
/src/build/Release/_deps/boost-src/libs/lexical_cast/include/boost/lexical_cast/bad_lexical_cast.hpp:97:45: error: must ‘#include <typeinfo>’ before using ‘typeid’
   97 |         const std::type_info& target_type = typeid(T);
      |                                             ^~~~~~~~~
[10/20] Linking CXX executable stage/bin/ExampleAsio
ninja: build stopped: subcommand failed.
root@23cd2d07fb08:/src#
```
