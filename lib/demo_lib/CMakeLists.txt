cmake_minimum_required(VERSION 3.10)

# Set library name
set(PROJECT_NAME demo_lib)  # Set project name manually
#get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)  # Set project name with dir name

# Set programming language
set(PROJECT_LANGUAGE C CXX)

# Set library version
set(LIB_VERSION_MAJOR 1)
set(LIB_VERSION_MINOR 2)
set(LIB_VERSION_PATCH 3)
set(LIB_VERSION ${LIB_VERSION_MAJOR}.${LIB_VERSION_MINOR}.${LIB_VERSION_PATCH})

# Set library public headers
set(PROJECT_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/demo.h)

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
project(${PROJECT_NAME} ${PROJECT_LANGUAGE})

# Add definition
if(CMAKE_BUILD_TYPE MATCHES Debug)
    add_definitions(-DDEBUG)
endif()

# Include directory
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Set file list
file(GLOB PROJECT_SRCS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    )

# Build library
add_library(${PROJECT_NAME} ${PROJECT_SRCS})
set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 11
    OUTPUT_NAME ${PROJECT_NAME}
    VERSION "${LIB_VERSION}"
    SOVERSION "${LIB_VERSION_MAJOR}.${LIB_VERSION_MINOR}"
    )

if(${BUILD_SHARED_LIBS})
    target_link_libraries(${PROJECT_NAME} ${PROJECT_DEPS})
endif()

# Install
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/bin"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_PREFIX}/include"
    )
install(FILES ${PROJECT_HEADERS}
    DESTINATION "${CMAKE_INSTALL_PREFIX}/include"
    )
