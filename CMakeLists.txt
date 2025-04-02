cmake_minimum_required(VERSION 3.15)

project(miniloader)

set(MODULE "" CACHE STRING "System module")
if(NOT MODULE)
    message(FATAL_ERROR "Option 'MODULE' must be set")
endif()

set(DLL_LOAD "" CACHE STRING "Path or filename to be loaded")
if (NOT DLL_LOAD)
    message(FATAL_ERROR "Option 'DLL_LOAD' must be set")
endif()

add_library(miniloader SHARED main.c ${MODULE}.def)

target_compile_definitions(miniloader PRIVATE DLL_LOAD=\"{DLL_LOAD}\")

set_target_properties(miniloader PROPERTIES RUNTIME_OUTPUT_NAME "${MODULE}")

target_link_libraries(miniloader PRIVATE ${CMAKE_SOURCE_DIR}/${MODULE}.lib)
