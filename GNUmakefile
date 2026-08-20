# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
# Standard stuff

.SUFFIXES:

MAKEFLAGS+= --no-builtin-rules
MAKEFLAGS+= --no-builtin-variables
MAKEFLAGS+= --warn-undefined-variables

#####################################################################

export CMAKE_CONFIG_TYPE=Release
export CMAKE_CONFIGURATION_TYPES="Release;Debug"
export CMAKE_EXPORT_COMPILE_COMMANDS=YES
export CMAKE_GENERATOR=Ninja
export CMAKE_INSTALL_PREFIX="${HOME}/.local"
export CMAKE_PREFIX_PATH="${HOME}/.local"
export CTEST_OUTPUT_ON_FAILURE=YES

#####################################################################

export hostSystemName:=$(shell uname)
export PATH:=${HOME}/.local/bin:${PATH}

ifeq ($(origin CXX),default)
  export CXX:= clang++
  export CC:= clang
  export GCOV:="llvm-cov gcov"
  # export CXXFLAGS:= -stdlib=libc++ -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0
endif

ifeq (${hostSystemName},Linux)
  export LANG:=C.UTF-8
  export LC_ALL:=C.UTF-8
endif

IMAGE?=ghcr.io/bemanproject/infra-containers-clang:latest

#####################################################################

.PHONY: all fresh disabled_modules build ctest install examples format clean distclean

all: ctest ## Make all with cmake with verbose cusomized workflow preset

# NOTE: Works only with clang v22.1.8 with different C++26 standard and cmake v4.4.x! CK
examples: # XXX install
	cmake -S examples -B build -G Ninja --log-level=VERBOSE --fresh \
	-D CMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON} \
	-D CMAKE_CXX_MODULE_STD=ON -D CMAKE_CXX_STANDARD=26 \
	-D BOOST_USE_MODULES=ON \
		--debug-find-pkg=Boost
	ninja -C build test -v

fresh: CMakePresets.json ## Make all with cmake Release workflow preset
	cmake --workflow --preset Release --fresh

compile_commands.json: build/Release/compile_commands.json ## Configure cmake preset in verbose mode
	ln -sf $< .

# NOTE: Works only with clang v22.1.8 with this arguments and cmake v4.4.x! CK
build/Release/compile_commands.json: GNUmakefile CMakeLists.txt
	cmake --version
	cmake --preset Release --log-level=VERBOSE -D BOOST_USE_MODULES=ON \
	-D CMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON} \
	-D CMAKE_CXX_MODULE_STD=ON -D CMAKE_CXX_STANDARD=23

build: compile_commands.json ## Run build preset
	cmake --build --preset Release

ctest: install ## Run ctest preset
	ctest --preset Release

install: build ## Install the cmake config package
	# XXX cmake --build --preset Release --target install
	cmake --install build/Release --config Release --prefix=${HOME}/.local/

clean: ## Clean build tree
	-cmake --build --preset Release --target clean

disabled_modules: CXX=c++
disabled_modules: ## Build w/o modules with default host compiler
	cmake --preset Release -D CMAKE_CXX_SCAN_FOR_MODULES=OFF -D BOOST_USE_MODULES=OFF

distclean: ## Make it really clean
	rm -rf build stagedir .cache compile_commands.json
	-find . -name '*~' -delete

format: ## Format cmake and source files
	git ls-files ::*.cmake ::*CMakeLists.txt | xargs gersemi -i --no-warn-about-unknown-commands --line-length 98
	-git ls-files ::*.json ::*.cpp ::*.hpp | xargs clang-format -i

# Helper targets
.PHONY: env info dockerbuild

dockerbuild: ## Start docker image interactive
	docker run -it -v $(CURDIR):/src $(IMAGE)

env: ## Show env
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

info: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[.a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

# Anything we don't know how to build will use this rule.
% ::
	ninja -C build/Release $(@)
