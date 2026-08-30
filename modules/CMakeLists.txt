# Generic optional module build for Chipa MOP_V2_Repack.
#
# A module is built only when it explicitly provides chipa_module.cmake.
# This avoids compiling arbitrary upstream module trees before they have been
# adapted and verified for the Chipa MoP 5.4.8 runtime.

message(STATUS "")
message(STATUS "* Configuring Chipa modules")

set(CHIPA_MODULE_SOURCES)
set(CHIPA_MODULE_INCLUDE_DIRS)
set(CHIPA_MODULES_FORWARD_DECL "")
set(CHIPA_MODULES_INVOKE "")
set(CHIPA_MODULE_NAMES)

file(GLOB CHIPA_MODULE_CANDIDATES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/*)

foreach(CHIPA_MODULE_DIR ${CHIPA_MODULE_CANDIDATES})
  set(CHIPA_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${CHIPA_MODULE_DIR})
  set(CHIPA_MODULE_MANIFEST ${CHIPA_MODULE_PATH}/chipa_module.cmake)

  if(IS_DIRECTORY ${CHIPA_MODULE_PATH} AND EXISTS ${CHIPA_MODULE_MANIFEST})
    unset(CHIPA_MODULE_NAME)
    unset(CHIPA_MODULE_LOADER)
    unset(CHIPA_MODULE_SOURCES_LOCAL)
    unset(CHIPA_MODULE_INCLUDE_DIRS_LOCAL)

    set(_CHIPA_GLOBAL_SOURCES ${CHIPA_MODULE_SOURCES})
    set(_CHIPA_GLOBAL_INCLUDE_DIRS ${CHIPA_MODULE_INCLUDE_DIRS})

    unset(CHIPA_MODULE_SOURCES)
    unset(CHIPA_MODULE_INCLUDE_DIRS)
    include(${CHIPA_MODULE_MANIFEST})

    set(CHIPA_MODULE_SOURCES_LOCAL ${CHIPA_MODULE_SOURCES})
    set(CHIPA_MODULE_INCLUDE_DIRS_LOCAL ${CHIPA_MODULE_INCLUDE_DIRS})
    set(CHIPA_MODULE_SOURCES ${_CHIPA_GLOBAL_SOURCES})
    set(CHIPA_MODULE_INCLUDE_DIRS ${_CHIPA_GLOBAL_INCLUDE_DIRS})

    if(NOT CHIPA_MODULE_NAME OR NOT CHIPA_MODULE_LOADER)
      message(FATAL_ERROR "Invalid Chipa module manifest: ${CHIPA_MODULE_MANIFEST}")
    endif()

    if(NOT CHIPA_MODULE_SOURCES_LOCAL)
      message(FATAL_ERROR "Chipa module '${CHIPA_MODULE_NAME}' has no explicit sources")
    endif()

    list(APPEND CHIPA_MODULE_SOURCES ${CHIPA_MODULE_SOURCES_LOCAL})
    list(APPEND CHIPA_MODULE_INCLUDE_DIRS ${CHIPA_MODULE_INCLUDE_DIRS_LOCAL})
    list(APPEND CHIPA_MODULE_NAMES ${CHIPA_MODULE_NAME})

    set(CHIPA_MODULES_FORWARD_DECL "${CHIPA_MODULES_FORWARD_DECL}void ${CHIPA_MODULE_LOADER}();\n")
    set(CHIPA_MODULES_INVOKE "${CHIPA_MODULES_INVOKE}    ${CHIPA_MODULE_LOADER}();\n")

    message(STATUS "  + module: ${CHIPA_MODULE_NAME}")
  endif()
endforeach()

if(CHIPA_MODULE_INCLUDE_DIRS)
  list(REMOVE_DUPLICATES CHIPA_MODULE_INCLUDE_DIRS)
endif()

set(CHIPA_GENERATED_MODULES_LOADER ${CMAKE_CURRENT_BINARY_DIR}/ModulesLoader.cpp)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/ModulesLoader.cpp.in ${CHIPA_GENERATED_MODULES_LOADER} @ONLY)

add_library(modules STATIC
  ${CHIPA_MODULE_SOURCES}
  ${CHIPA_GENERATED_MODULES_LOADER}
)

target_include_directories(modules
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CHIPA_MODULE_INCLUDE_DIRS}
  PRIVATE
    ${CMAKE_BINARY_DIR}
    $<TARGET_PROPERTY:game,INCLUDE_DIRECTORIES>
)

target_link_libraries(modules game)
add_dependencies(modules game revision.h)

# src/ is configured before modules/, therefore worldserver already exists.
# Linking here keeps the generic module integration out of worldserver's own
# CMakeLists.txt and preserves a smaller Core diff.
if(TARGET worldserver)
  target_link_libraries(worldserver modules)
endif()

if(CHIPA_MODULE_NAMES)
  list(LENGTH CHIPA_MODULE_NAMES CHIPA_MODULE_COUNT)
  message(STATUS "* Configured ${CHIPA_MODULE_COUNT} Chipa module(s)")
else()
  message(STATUS "* No Chipa module manifests found")
endif()
message(STATUS "")
