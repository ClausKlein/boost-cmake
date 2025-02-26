# Standard stuff

.SUFFIXES:

MAKEFLAGS+= --no-builtin-rules
MAKEFLAGS+= --warn-undefined-variables

.PHONY: all fresh configure build test install format clean distclean

fresh:
	cmake --workflow --preset Release --fresh

all: test

configure:
	cmake --preset Release

build: configure
	cmake --build --preset Release

test: install
	ctest --preset Release

install: build
	cmake --build --preset Release --target install

clean:
	-cmake --build --preset Release --target clean

distclean: clean
	rm -rf build stagedir

format:
	git ls-files ::*.cmake ::*CMakeLists.txt | xargs gersemi -i
	git ls-files ::*.json ::*.cpp ::*.hpp | xargs clang-format -i
	# git clang-format master
