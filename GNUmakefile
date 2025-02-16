.PHONY: all fresh configure build test install format
all: build

fresh:
	cmake --workflow --preset Release --fresh

configure:
	cmake --preset Release

build: configure
	cmake --build --preset Release

test: build
	ctest --build --preset Release

install: test
	cmake --build --preset Release --target install

format:
	git clang-format
	find . \( -type d -name build -o -name stagedir \) -prune -o \( -name '*.cmake' -o -name CMakeLists.txt \) -print > .cmakefiles.log
	#NO! cmake-format -i `cat .cmakefiles.log`
	ls -1 *.json >> .cmakefiles.log
	cmake-format -i CMakeLists.txt cmake/*.cmake cmake/*/*.cmake
