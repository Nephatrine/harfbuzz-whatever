cmake_minimum_required(VERSION 3.3.2)

project(harfbuzz_we
	VERSION 1.3.1)

set(HARFBUZZ_SOVERSION ${PROJECT_VERSION_MINOR})

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/config/CMake")
set(WHATEVER_SET_LANGUAGE C)
include(WhatEver)

we_mark_license(LICENSE.md)
we_mark_docs(README.md)

#
# Project Source Code
#

list(APPEND HARFBUZZ_SOURCE
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-blob.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-buffer-serialize.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-buffer.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-common.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-face.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-font.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-tag.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-set.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-shape.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-shape-plan.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-shaper.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-unicode.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-warning.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-fallback-shape.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-font.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-layout.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-map.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-arabic.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-default.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-hangul.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-hebrew.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-indic.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-indic-table.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-myanmar.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-thai.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-tibetan.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-use.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-complex-use-table.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-normalize.cc"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ot-shape-fallback.cc")

#
# External Modules
#

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(freetype2_we CONFIG)
find_package(ucdn_we CONFIG)
find_package(Freetype)
find_package(GTK2)
find_package(Threads)

if(APPLE)
	find_library(APPLICATION_SERVICES_FRAMEWORK ApplicationServices)
	mark_as_advanced(APPLICATION_SERVICES_FRAMEWORK)
endif()

if(WIN32)
	find_library(DWRITE_LIBRARY dwrite)
	find_library(UNISCRIBE_LIBRARY usp10)
	mark_as_advanced(DWRITE_LIBRARY UNISCRIBE_LIBRARY)
endif()

#
# Project Options
#

cmake_dependent_option(HB_CONFIG_OPTION_USE_CORETEXT "Enable CoreText Shaper" ON APPLICATION_SERVICES_FRAMEWORK OFF)
if(HB_CONFIG_OPTION_USE_CORETEXT)
	set(HAVE_CORETEXT ON)
	list(APPEND HARFBUZZ_SOURCE
		"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-coretext.cc")
endif()

cmake_dependent_option(HB_CONFIG_OPTION_USE_DIRECTWRITE "Enable DirectWrite Shaper" OFF DWRITE_LIBRARY OFF)
if(HB_CONFIG_OPTION_USE_DIRECTWRITE)
	set(HAVE_DIRECTWRITE ON)
	list(APPEND HARFBUZZ_SOURCE
		"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-directwrite.cc")
endif()

cmake_dependent_option(HB_CONFIG_OPTION_USE_FREETYPE "Support FreeType2 Font Engine" ON "FREETYPE_FOUND OR freetype2_we_CONFIG" OFF)
if(HB_CONFIG_OPTION_USE_FREETYPE)
	list(APPEND HARFBUZZ_SOURCE
		"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ft.cc")
endif()

cmake_dependent_option(HB_CONFIG_OPTION_USE_GLIB "Use GLib Unicode Functions" OFF GTK2_GLIB_FOUND OFF)
if(HB_CONFIG_OPTION_USE_GLIB)
	set(HAVE_GLIB ON)
	list(APPEND HARFBUZZ_SOURCE
		"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-glib.cc")
endif()

cmake_dependent_option(HB_CONFIG_OPTION_USE_GRAPHITE "Use SIL Graphite Shaper" ON GRAPHITE2_FOUND OFF)
if(HB_CONFIG_OPTION_USE_GRAPHITE)
	set(HAVE_GRAPHITE2 ON)
	list(APPEND HARFBUZZ_SOURCE
		"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-graphite2.cc")
endif()

cmake_dependent_option(HB_CONFIG_OPTION_USE_ICU "Use ICU Unicode Functions" OFF ICU_FOUND OFF)
if(HB_CONFIG_OPTION_USE_ICU)
	set(HAVE_ICU ON)
	list(APPEND HARFBUZZ_SOURCE
		"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-icu.cc")
endif()

cmake_dependent_option(HB_CONFIG_OPTION_USE_PTHREAD "Use PThreads Threading Library" ON CMAKE_USE_PTHREADS_INIT OFF)
if(HB_CONFIG_OPTION_USE_PTHREAD)
	set(HAVE_PTHREAD ON)
endif()

cmake_dependent_option(HB_CONFIG_OPTION_USE_UCDN "Use UCDN Unicode Functions" ON ucdn_we_CONFIG OFF)
if(HB_CONFIG_OPTION_USE_UCDN)
	set(HAVE_UCDN ON)
	list(APPEND HARFBUZZ_SOURCE
		"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-ucdn.cc")
endif()

cmake_dependent_option(HB_CONFIG_OPTION_USE_UNISCRIBE "Enable Uniscribe Shaper" ON UNISCRIBE_LIBRARY OFF)
if(HB_CONFIG_OPTION_USE_UNISCRIBE)
	set(HAVE_UNISCRIBE ON)
	list(APPEND HARFBUZZ_SOURCE
		"${CMAKE_CURRENT_SOURCE_DIR}/src/hb-uniscribe.cc")
endif()

#
# Compiler Tests
#

we_atomic_builtins()

if(HAVE_BUILTIN_ATOMIC)
	set(HAVE_GCC_ATOMIC_PRIMITIVES ON)
endif()

if(HAVE_BUILTIN_SYNC)
	set(HAVE_INTEL_ATOMIC_PRIMITIVES ON)
endif()

if(NOT MSVC)
	we_request_compile_flag("-march=native")
	we_request_compile_flag("-Wextra")
	we_request_link_flag("-Wl,--as-needed")
	we_request_link_flag("-Wl,--no-undefined")
	we_request_link_flag("-Wl,--no-allow-shlib-undefined")

	# so we dont link to libstdc++
	we_request_compile_flag("-fno-exceptions")

	if(MINGW)
		we_request_link_flag("-Wl,--nxcompat")
		we_request_link_flag("-Wl,--dynamicbase")
		we_request_link_flag("-Wl,--high-entropy-va")
	endif()
endif()

we_check_function(sched.h sched_yield)
we_check_function(stdlib.h atexit)
we_check_function(sys/mman.h mprotect)
we_check_function(unistd.h getpagesize)
we_check_function(unistd.h sysconf)

#
# Generate Configuration Headers
#

we_generate_configs("${CMAKE_CURRENT_SOURCE_DIR}/config"
	"${CMAKE_CURRENT_BINARY_DIR}/include")
we_generate_configs("${CMAKE_CURRENT_SOURCE_DIR}/config/internal"
	"${CMAKE_CURRENT_BINARY_DIR}/include/internal")
list(APPEND HARFBUZZ_HEADERS ${WHATEVER_GENERATED})

#
# Build Project Libraries
#

option(BUILD_LIBRARY_STATIC "Build Static Library" ON)
if(BUILD_LIBRARY_STATIC)
	we_build_library_static(HARFBUZZ_STATIC ${PROJECT_NAME} ${HARFBUZZ_SOVERSION} "${HARFBUZZ_SOURCE};${HARFBUZZ_HEADERS}")
endif()

option(BUILD_LIBRARY_SHARED "Build Shared Library" ON)
if(BUILD_LIBRARY_STATIC)
	we_build_library_shared(HARFBUZZ_SHARED ${PROJECT_NAME} ${HARFBUZZ_SOVERSION} "${HARFBUZZ_SOURCE};${HARFBUZZ_HEADERS}")
endif()

we_include_public("${WHATEVER_TARGETS_LIBRARY}" include "${PROJECT_NAME}-${HARFBUZZ_SOVERSION}")
we_include_private("${WHATEVER_TARGETS_LIBRARY}" src)

#
# Link External Libraries
#

if(HB_CONFIG_OPTION_USE_CORETEXT AND APPLICATION_SERVICES_FRAMEWORK)
	list(APPEND HARFBUZZ_EXT_LIB ${APPLICATION_SERVICES_FRAMEWORK})
endif()

if(HB_CONFIG_OPTION_USE_DIRECTWRITE)
	list(APPEND HARFBUZZ_EXT_LIB dwrite rpcrt4)
endif()

if(HB_CONFIG_OPTION_USE_FREETYPE)
	if(freetype2_we_CONFIG)
		list(APPEND HARFBUZZ_EXT_LIB libfreetype2_we)
	else()
		list(APPEND FREETYPE_EXT_LIB ${FREETYPE_LIBRARIES})
		list(APPEND FREETYPE_EXT_INC ${FREETYPE_INCLUDE_DIRS})
	endif()
endif()

if(HB_CONFIG_OPTION_USE_GLIB)
	list(APPEND HARFBUZZ_EXT_LIB GTK2::glib)
endif()

if(HB_CONFIG_OPTION_USE_PTHREAD)
	list(APPEND HARFBUZZ_EXT_LIB Threads::Threads)
endif()

if(HB_CONFIG_OPTION_USE_UCDN)
	list(APPEND HARFBUZZ_EXT_LIB libucdn_we)
endif()

if(HB_CONFIG_OPTION_USE_UNISCRIBE)
	list(APPEND HARFBUZZ_EXT_LIB usp10 gdi32 rpcrt4)
endif()

we_external_include("${WHATEVER_TARGETS_LIBRARY}" PRIVATE "${HARFBUZZ_EXT_INC}")
we_external_library("${WHATEVER_TARGETS_SHARED}" PRIVATE "${HARFBUZZ_EXT_LIB}")
we_external_library("${WHATEVER_TARGETS_STATIC}" PUBLIC "${HARFBUZZ_EXT_LIB}")

#
# Create Installation Packages
#

we_package(harfbuzz Nephatrine nephatrine@gmail.com "Open Source Text Shaping")
we_generate_exports("${WHATEVER_TARGETS_LIBRARY}")

