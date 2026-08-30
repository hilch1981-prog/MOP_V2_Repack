# Copyright (C) 2011-2016 Project SkyFire <http://www.projectskyfire.org/>
# Copyright (C) 2008-2016 TrinityCore <http://www.trinitycore.org/>

cmake_minimum_required(VERSION 3.5...3.31)

if (UNIX)
  if (EXISTS "/usr/bin/gcc-4.9")
    message (STATUS "gcc 4.9 found. Force switching to 4.8")
    if (NOT EXISTS "/usr/bin/gcc-4.8")
      message (FATAL_ERROR "gcc 4.8 not found")
    endif()
    if (NOT EXISTS "/usr/bin/g++-4.8")
      message (FATAL_ERROR "g++ 4.8 not installed")
    endif()
    set (CMAKE_C_COMPILER "/usr/bin/gcc-4.8")
    set (CMAKE_CXX_COMPILER "/usr/bin/g++-4.8")
  endif()
endif()

project(Pandaria_5.4.8)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
set(CMAKE_SKIP_BUILD_RPATH 0)
set(CMAKE_BUILD_WITH_INSTALL_RPATH 0)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH 1)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/macros")

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
endif()

include(CheckCXXSourceRuns)
include(CheckIncludeFiles)
include(cmake/options.cmake)

if(NOPCH)
  set(USE_COREPCH 0)
  set(USE_SCRIPTPCH 0)
endif()

include(CheckPlatform)

set(OPENSSL_EXPECTED_VERSION 1.0.0)
set(BOOST_EXPECTED_VERSION 1.70)

find_package(PCHSupport)
find_package(OpenSSL ${OPENSSL_EXPECTED_VERSION} REQUIRED)
find_package(Threads REQUIRED)
find_package(MySQL REQUIRED)

if(UNIX)
  find_package(Readline)
  find_package(ZLIB)
  find_package(BZip2)
endif()

set(Boost_USE_STATIC_LIBS ON)
find_package(Boost ${BOOST_EXPECTED_VERSION} COMPONENTS
  system
  locale
  filesystem
  thread
  regex
  serialization
  date_time
  REQUIRED
)

include(cmake/genrev.cmake)
include(cmake/showoptions.cmake)

add_subdirectory(dep)
add_subdirectory(src)

# Optional generic modules are configured only after src/ so the game target
# and its include directories already exist.
if(MODULES AND SERVERS)
  add_subdirectory(modules)
endif()
