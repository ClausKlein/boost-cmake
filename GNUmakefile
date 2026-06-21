# Standard stuff

.SUFFIXES:

MAKEFLAGS+= --no-builtin-rules
MAKEFLAGS+= --warn-undefined-variables

export hostSystemName=$(shell uname)

ifeq (${hostSystemName},Darwin)
  export LLVM_PREFIX:=$(shell brew --prefix llvm)
  export LLVM_DIR:=$(shell realpath ${LLVM_PREFIX})
  export PATH:=${LLVM_DIR}/bin:${PATH}

  export CMAKE_CXX_STDLIB_MODULES_JSON:=${LLVM_DIR}/lib/c++/libc++.modules.json
  export CXX:=clang++
  export LDFLAGS:=-L$(LLVM_DIR)/lib/c++ -lc++abi # NO! -lc++ -lc++experimental
  export GCOV:="llvm-cov gcov"

  ### TODO: to test g++-15:
  export GCC_PREFIX:=$(shell brew --prefix gcc)
  export GCC_DIR:=$(shell realpath ${GCC_PREFIX})

  # export CMAKE_CXX_STDLIB_MODULES_JSON:=${GCC_DIR}/lib/gcc/current/libstdc++.modules.json
  # export CXX:=g++-15
  # export CXXFLAGS:=-stdlib=libstdc++
  # export GCOV:="gcov"
else ifeq (${hostSystemName},Linux)
  export LLVM_DIR:=/usr/lib/llvm-20
  export PATH:=${LLVM_DIR}/bin:${PATH}
  export CXX:=clang++-20
endif

#####################################################################
.PHONY: all fresh build test install examples format clean distclean

all: test

examples: # XXX install
	cmake -S examples -B build -G Ninja --log-level=VERBOSE --fresh \
		--debug-find-pkg=Boost
	ninja -C build test -v

fresh:
	cmake --workflow --preset Release --fresh

compile_commands.json: build/Release/compile_commands.json
	ln -sf $< .

build/Release/compile_commands.json: GNUmakefile CMakeLists.txt
	cmake --preset Release --log-level=VERBOSE -D BOOST_USE_MODULES=ON

build: compile_commands.json
	cmake --build --preset Release

test: install
	ctest --preset Release

install: build
	cmake --build --preset Release --target install

clean:
	-cmake --build --preset Release --target clean
	-find . -name '*~' -delete

distclean: # XXX clean
	rm -rf build stagedir

format:
	git ls-files ::*.cmake ::*CMakeLists.txt | xargs gersemi -i
	git ls-files ::*.json ::*.cpp ::*.hpp | xargs clang-format -i
	# git clang-format master
