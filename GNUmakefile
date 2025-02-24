# Standard stuff

.SUFFIXES:

MAKEFLAGS+= --no-builtin-rules
MAKEFLAGS+= --warn-undefined-variables

.PHONY: all fresh configure build test install format clean distclean
all: build

fresh:
	cmake --workflow --preset Release --fresh

configure:
	cmake --preset Release

build: configure
	cmake --build --preset Release

test: build
	ctest --build --preset Release

install: # test
	cmake --build --preset Release --target install

clean:
	-cmake --build --preset Release --target clean

distclean: clean
	rm -rf build stagedir


format:
	git ls-files ::*.cmake ::*CMakeLists.txt | xargs gersemi -i
	git ls-files ::*.json | xargs clang-format -i
	git clang-format master
