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
# export CMAKE_INSTALL_PREFIX="${HOME}/.local"
# export CMAKE_PREFIX_PATH="${HOME}/.local"
export CTEST_OUTPUT_ON_FAILURE=YES

#####################################################################

export PATH:=${HOME}/.local/bin:${PATH}

ifeq ($(origin CC),default)
  export CC:= gcc-16
endif

ifeq ($(origin CXX),default)
  export CXX:= g++-16
  # XXX export GCOV:="llvm-cov gcov"
  # TODO: only needed to fix clang++ problem on infra-containers-clang
  # export CXXFLAGS:= -stdlib=libc++ -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0
endif

# CXX_VERSION:=$(shell ${CXX} -dumpversion)
hostSystemName:=$(shell uname)

ifeq (${hostSystemName},Linux)
  export LANG:=C.UTF-8
  export LC_ALL:=C.UTF-8
endif

IMAGE?=ghcr.io/bemanproject/infra-containers-clang:latest

#####################################################################

.PHONY: all cxx_module cxx_module_std disabled_modules build ctest install examples format clean distclean

all: ctest ## Make all with cmake with cusomized workflow preset in verbose mode

# NOTE: Works only with clang v22.1.8 with different C++26 standard and cmake v4.4.x! CK
examples: # XXX install ## Build examples as standalone project to test installed config package
	cmake -S examples -B build -G Ninja -D CMAKE_MESSAGE_LOG_LEVEL=VERBOSE --fresh \
	    -D BOOST_USE_MODULES=ON \
	    -D CMAKE_CXX_MODULE_STD=ON \
	    -D CMAKE_CXX_STANDARD=26 \
	    --debug-find-pkg=Boost
	ninja -C build test -v

cxx_module: CMakePresets.json ## Run cmake workflow preset Release with BOOST_USE_MODULES
	cmake --preset Release --log-level=VERBOSE --fresh
	ln -sf build/Release/compile_commands.json .
	# TODO: cmake --workflow --preset Release --fresh

cxx_module_std: compile_commands.json ## Configure with CXX_MODULE_STD set in verbose mode
compile_commands.json: build/Release/compile_commands.json
	ln -sf $< .

# NOTE: Works only with clang v22.1.8 with this arguments and cmake v4.4.x! CK
build/Release/compile_commands.json: GNUmakefile CMakeLists.txt
	modules_json_option=""; \
	case "$${CXX##*/}" in \
	    clang++|clang++-[0-9]*) \
	        source_json=/lib/x86_64-linux-gnu/libc++.modules.json; \
	        patched_json="$${PWD}/build/Release/libc++.modules.json"; \
	        if test -r /etc/os-release && \
	            grep -q '^ID=ubuntu$$' /etc/os-release && \
	            test -n "$${CI:-}" && \
	            test -n "$${LLVM_PATH:-}" && \
	            test -r "$${source_json}"; then \
	                mkdir -p "$${patched_json%/*}"; \
	                sed -e "s#\\.\\./share/libc++#$${LLVM_PATH}/share/libc++#" \
	                    "$${source_json}" > "$${patched_json}"; \
	            modules_json_option="-D CMAKE_CXX_STDLIB_MODULES_JSON=$${patched_json}"; \
	        fi; \
	        ;; \
	esac; \
	cmake --version; \
	cmake --preset Release --log-level=VERBOSE --fresh \
	    -D BOOST_USE_MODULES=ON \
	    -D CMAKE_CXX_MODULE_STD=ON \
	    -D CMAKE_CXX_STANDARD=23 \
	    $${modules_json_option}

build: compile_commands.json ## Run build preset
	cmake --build --preset Release

ctest: install ## Run ctest preset
	ctest --preset Release

install: build ## Install the cmake config package
	cmake --build --preset Release --target install
	# XXX cmake --install build/Release --config Release --prefix=${HOME}/.local/

clean: ## Clean build tree
		-cmake --build --preset Release --target clean

disabled_modules: ## Build with disabled CXX_SCAN_FOR_MODULES
	cmake --preset Release --log-level=VERBOSE --fresh \
	    -D BOOST_USE_MODULES=OFF \
	    -D CMAKE_CXX_SCAN_FOR_MODULES=OFF

distclean: ## Make it really clean
	rm -rf build stagedir .cache compile_commands.json
	-find . -name '*~' -delete

format: ## Format cmake and source files
	git ls-files ::*.cmake ::*CMakeLists.txt | xargs gersemi -i --no-warn-about-unknown-commands --line-length 98
	-git ls-files ::*.json ::*.cpp ::*.hpp | xargs clang-format -i

# Helper targets
.PHONY: env info dockerbuild

dockerbuild: ## Start docker ${IMAGE} interactive
	docker run -it -v $(CURDIR):/src $(IMAGE)

env: ## Show env
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

info: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[.a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

# Anything we don't know how to build will use this rule.
% ::
	ninja -C build/Release $(@)
