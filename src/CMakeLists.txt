# Copyright (C) 2011-2016 Project SkyFire <http://www.projectskyfire.org/>
# Copyright (C) 2008-2016 TrinityCore <http://www.trinitycore.org/>

add_subdirectory(genrev)
add_subdirectory(server)

# Chipa optional module framework. This is deliberately configured only after
# server targets exist so modules can link against game/scripts/worldserver
# without introducing a Core -> module source dependency.
option(MODULES "Build modules from the top-level modules/ directory" 1)
if(SERVERS AND MODULES)
  add_subdirectory(${CMAKE_SOURCE_DIR}/modules ${CMAKE_BINARY_DIR}/modules)
endif()

if(TOOLS)
  if(MSVC)
    add_subdirectory(tools)
  else()
    add_definitions(-std=c++11)
    add_subdirectory(tools)
  endif()
endif(TOOLS)

if(UPDATER)
  add_subdirectory(updater)
endif()
