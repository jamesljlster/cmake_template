cmake_minimum_required(VERSION 3.10)

# Disable in-source builds to prevent source tree corruption.
if(" ${CMAKE_SOURCE_DIR}" STREQUAL " ${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "\nFATAL: In-source builds are not allowed.\n"
        "You should create a separate directory for build files."
        )
endif()

# Set variables
set(PROJECT_NAME CMake_Template)
set(PROJECT_LANGUAGE C CXX CUDA)

# Environment variables
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation directory")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
option(BUILD_TEST "Enable building test" OFF)
option(BUILD_SHARED_LIBS "Build shared library" OFF)

set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Build configure")
if(CMAKE_BUILD_TYPE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CMAKE_CONFIGURATION_TYPES})
else()
    set(CMAKE_BUILD_TYPE Release)
endif()

# Export compile commands (For some useful tools like YCM, Sourcetrail, ...)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# Initialize RPATH settings for shared library loading
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

if(NOT CMAKE_INSTALL_RPATH)
    set(CMAKE_INSTALL_RPATH "" CACHE INTERNAL "RPATH for installation")
endif()

# Dependences paths
set(DEPS_PATHS
    #"${CMAKE_CURRENT_SOURCE_DIR}/deps/foo"
    )

# Library paths
set(LIB_PATHS
    "${CMAKE_CURRENT_SOURCE_DIR}/lib/demo_lib"
    )

# Utility paths
set(UTIL_PATHS
    "${CMAKE_CURRENT_SOURCE_DIR}/util/demo_util"
    )

if(${BUILD_TEST})
    set(UTIL_PATHS ${UTIL_PATHS} "${CMAKE_CURRENT_SOURCE_DIR}/test")
endif()

# Set project
project(${PROJECT_NAME} ${PROJECT_LANGUAGE})

# Resolve CUDA architectures
include(CUDAHelper)
resolve_cuda_architectures("COMMON" ARCH_MIN "52" CUDA_MIN "9.0")

# Include cmake files
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/deps.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/lib.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/util.cmake")
