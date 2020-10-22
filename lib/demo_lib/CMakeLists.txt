cmake_minimum_required(VERSION 3.10)

# Set library name
set(PROJECT_NAME demo_lib)  # Set project name manually
#get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)  # Set project name with dir name

# Set programming language
set(PROJECT_LANGUAGE C CXX)

# Set library version
set(PROJECT_VERSION 1.2.3)

# Set library public headers
set(PROJECT_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/demo.h")

# Set library dependencies
set(PROJECT_DEPS gcc stdc++)

# Compile setting
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
set(CMAKE_C_FLAGS_RELEASE "-O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

# Set default build option
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

if(NOT BUILD_SHARED_LIBS)
    set(BUILD_SHARED_LIBS OFF)
endif()

# Set project
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGE})

# Add definition
if(CMAKE_BUILD_TYPE MATCHES Debug)
    add_definitions(-DDEBUG)
endif()

# Include directory
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Set file list
file(GLOB PROJECT_SRCS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    )

# Configure package install prefix
set(BIN_DIR "bin")
set(LIB_DIR "lib/${PROJECT_NAME}")
set(INC_DIR "include/${PROJECT_NAME}")
set(EXPORT_DIR "lib/cmake/${PROJECT_NAME}")

# Setup RPATH for shared library loading
if((DEFINED CMAKE_INSTALL_RPATH) AND (${BUILD_SHARED_LIBS}))
    if(NOT ${LIB_DIR} IN_LIST CMAKE_INSTALL_RPATH)
        list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES ${LIB_DIR} isSystemDir)
        if("${isSystemDir}" STREQUAL "-1")
            list(APPEND CMAKE_INSTALL_RPATH ${LIB_DIR})
            set(CMAKE_INSTALL_RPATH ${CMAKE_INSTALL_RPATH} CACHE INTERNAL
                "RPATH for installation" FORCE)
        endif()
    endif()
endif()

# Build library
add_library(${PROJECT_NAME} ${PROJECT_SRCS})
set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 11
    OUTPUT_NAME ${PROJECT_NAME}
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    )

if(${BUILD_SHARED_LIBS})
    target_link_libraries(${PROJECT_NAME} ${PROJECT_DEPS})
endif()

# Install
set(LIB_TARGET ${PROJECT_NAME}-targets)
install(EXPORT ${LIB_TARGET} DESTINATION ${EXPORT_DIR})

install(TARGETS ${PROJECT_NAME} EXPORT ${LIB_TARGET}
    RUNTIME DESTINATION ${BIN_DIR}
    ARCHIVE DESTINATION ${LIB_DIR}
    LIBRARY DESTINATION ${LIB_DIR}
    PUBLIC_HEADER DESTINATION ${INC_DIR}
    )

install(FILES ${PROJECT_HEADERS} DESTINATION ${INC_DIR})

# Export package configuration
include(CMakePackageConfigHelpers)

set(LIB_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake")
set(LIB_VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-version.cmake")

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.cmake.in" ${LIB_CONFIG_FILE}
    INSTALL_DESTINATION ${EXPORT_DIR}
    PATH_VARS INC_DIR LIB_DIR
    )

write_basic_package_version_file(
    ${LIB_VERSION_FILE}
    VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    COMPATIBILITY SameMajorVersion
)

install(FILES ${LIB_CONFIG_FILE} ${LIB_VERSION_FILE} DESTINATION ${EXPORT_DIR})
