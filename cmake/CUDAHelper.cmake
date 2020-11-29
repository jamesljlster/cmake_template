# MIT License
#
# Copyright (c) 2020 Cheng-Ling Lai
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# ============================
#  RESOLVE_CUDA_ARCHITECTURES
# ============================
#
#  Brief
#
#    Resolve CUDA architectures for compilation. With given resolving strategy
#    and parameters, this function will fill CMAKE_CUDA_ARCHITECTURES and
#    modify CMAKE_CUDA_FLAGS if it's necessary (CMake version < 3.18).
#
#  Usage
#
#    RESOLVE_CUDA_ARCHITECTURES(STRATEGY [ARCH_MIN archMin] [CUDA_MIN cudaMin]
#                               [VERBOSE])
#
#  Parameters
#
#    STRATEGY [ALL|COMMON]:
#      Sames as FIND_CUDA_ARCHITECTURES documented.
#
#    ARCH_MIN archMin:
#      Sames as FIND_CUDA_ARCHITECTURES documented.
#
#    CUDA_MIN cudaMin:
#      Sames as FIND_CUDA_ARCHITECTURES documented.
#
#    VERBOSE:
#      Sames as FIND_CUDA_ARCHITECTURES documented.
#
macro(RESOLVE_CUDA_ARCHITECTURES)

    # Parse parameters
    cmake_parse_arguments(ARG "VERBOSE" "" "" ${ARGN})

    # Find and apply CUDA architectures
    find_cuda_architectures(${ARGN})
    debug_info("Modify CMAKE_CUDA_ARCHITECTURES to: ${CMAKE_CUDA_ARCHITECTURES}")

    if(${CMAKE_VERSION} VERSION_LESS "3.18")
        foreach(CUDA_ARCH ${CMAKE_CUDA_ARCHITECTURES})
            string(CONCAT CMAKE_CUDA_FLAGS
                "${CMAKE_CUDA_FLAGS} "
                "--generate-code=arch=compute_${CUDA_ARCH},"
                "code=[compute_${CUDA_ARCH},sm_${CUDA_ARCH}]")
        endforeach()
        debug_info("Modify CMAKE_CUDA_FLAGS to: ${CMAKE_CUDA_FLAGS}")
    endif()

endmacro()


# =========================
#  FIND_CUDA_ARCHITECTURES
# =========================
#
#  Brief
#
#    Find CUDA architectures for compilation.
#
#  Usage
#
#    FIND_CUDA_ARCHITECTURES(STRATEGY [ARCH_MIN archMin] [CUDA_MIN cudaMin]
#                            [OUTPUT_VARIABLE outputVar] [VERBOSE])
#
#  Parameters
#
#    STRATEGY [ALL|COMMON]:
#      Use ALL for selecting all supported architectures for current working
#      cuda version. Use COMMON for auto filtering out common supported
#      architectures with given minimum architecture and CUDA version limit.
#
#    ARCH_MIN archMin:
#      Give a minimum limitation "archMin" for CUDA architecture.
#
#    CUDA_MIN cudaMin:
#      Give a minimum limitation "cudaMin" for CUDA version.
#
#    OUTPUT_VARIABLE outputVar:
#      Store final CUDA architecture list to "outputVar"
#
#    VERBOSE:
#      Show processing messages.
#
function(FIND_CUDA_ARCHITECTURES STRATEGY)

    # Constants
    set(MIN_SUPPORT_VER 7.0)
    set(CUDA_CONST_VERS 7.0 7.5 8.0 9.0 9.1 9.2 10.0 10.1 10.2 11.0 11.1)

    set(CUDA_ARCH_7.0  20 30 32 35 37 50 52 53)
    set(CUDA_ARCH_7.5  20 30 32 35 37 50 52 53)
    set(CUDA_ARCH_8.0  20 30 32 35 37 50 52 53 60 61 62)
    set(CUDA_ARCH_9.0     30 32 35 37 50 52 53 60 61 62 70)
    set(CUDA_ARCH_9.1     30 32 35 37 50 52 53 60 61 62 70 72)
    set(CUDA_ARCH_9.2     30 32 35 37 50 52 53 60 61 62 70 72)
    set(CUDA_ARCH_10.0    30 32 35 37 50 52 53 60 61 62 70 72 75)
    set(CUDA_ARCH_10.1    30 32 35 37 50 52 53 60 61 62 70 72 75)
    set(CUDA_ARCH_10.2    30 32 35 37 50 52 53 60 61 62 70 72 75)
    set(CUDA_ARCH_11.0          35 37 50 52 53 60 61 62 70 72 75 80)
    set(CUDA_ARCH_11.1          35 37 50 52 53 60 61 62 70 72 75 80 86)

    # Parse arguments
    set(OPT "VERBOSE")
    set(PARAM "ARCH_MIN;CUDA_MIN;OUTPUT_VARIABLE")
    set(M_PARAM)
    cmake_parse_arguments(ARG "${OPT}" "${PARAM}" "${M_PARAM}" ${ARGN})

    # Set default arguments
    if(NOT DEFINED ARG_ARCH_MIN)
        set(ARG_ARCH_MIN 00)
    endif()

    if(NOT DEFINED ARG_CUDA_MIN)
        set(ARG_CUDA_MIN ${MIN_SUPPORT_VER})
    endif()

    if(NOT DEFINED ARG_OUTPUT_VARIABLE)
        set(ARG_OUTPUT_VARIABLE CMAKE_CUDA_ARCHITECTURES)
    endif()

    # Parse CUDA compiler version
    if(CMAKE_CUDA_COMPILER_VERSION VERSION_LESS ${MIN_SUPPORT_VER})
        message(FATAL_ERROR
            "CUDAHelper Error: CUDA version less then ${MIN_SUPPORT_VER} is not supported"
            )
    endif()

    string(REPLACE "." ";" CUDA_VER ${CMAKE_CUDA_COMPILER_VERSION})
    list(GET CUDA_VER 0 CUDA_VER_MAJOR)
    list(GET CUDA_VER 1 CUDA_VER_MINOR)
    set(CUDA_VER "${CUDA_VER_MAJOR}.${CUDA_VER_MINOR}")
    debug_info("Parsed CUDA version: ${CUDA_VER}")

    # Check finding strategy
    set(STRATEGY_TYPES "ALL;COMMON")
    if(NOT ${STRATEGY} IN_LIST STRATEGY_TYPES)
        message(FATAL_ERROR
            "\"${STRATEGY}\" is not a supported CUDA architectures finding strategy"
            )
    endif()

    # Find all supported CUDA architectures list
    if((CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL "11.1") AND
            (NOT ${CUDA_VER} IN_LIST CUDA_CONST_VERS))

        # Find all supported architectures list by nvcc,
        # might be useful when this module is out of date
        execute_process(COMMAND
            ${CMAKE_CUDA_COMPILER}
            "--list-gpu-arch" OUTPUT_VARIABLE CUDA_ARCH_RAW
            )

        string(REGEX MATCHALL "([0-9])+" CUDA_ARCH_LIST ${CUDA_ARCH_RAW})

        # Append new list to constants
        list(APPEND CUDA_CONST_VERS "${CUDA_VER}")
        set(CUDA_ARCH_${CUDA_VER} ${CUDA_ARCH_LIST})
        debug_info("Add new arch list for ${CUDA_VER}: ${CUDA_ARCH_LIST}")

    else()

        # Get predefined architectures list
        set(CUDA_ARCH_LIST ${CUDA_ARCH_${CUDA_VER}})
        debug_info("Use predefined arch list for ${CUDA_VER}: ${CUDA_ARCH_LIST}")

    endif()

    # Apply minimum filter
    list_filter(CUDA_ARCH_LIST "LESS;${ARG_ARCH_MIN}")
    debug_info("List after removing arch less then ${ARG_ARCH_MIN}: ${CUDA_ARCH_LIST}")

    # Processing cuda architecture list
    if(STRATEGY MATCHES "COMMON")

        # Filter minimal filter for cuda versions
        set(FILTERED_VERS ${CUDA_CONST_VERS})
        list_filter(FILTERED_VERS "LESS;${ARG_CUDA_MIN}")
        debug_info("Find common architectures with CUDA versions: ${FILTERED_VERS}")

        # Union supported arch
        set(CUDA_ARCH_UNION ${CUDA_ARCH_LIST})
        foreach(VER ${FILTERED_VERS})
            if(${VER} VERSION_LESS ${CUDA_VER})
                list(APPEND CUDA_ARCH_UNION ${CUDA_ARCH_${VER}})
            endif()
        endforeach()

        list(REMOVE_DUPLICATES CUDA_ARCH_UNION)
        list(SORT CUDA_ARCH_UNION)

        # Find architectures not supported by all CUDA versions
        set(CUDA_ARCH_UNCOMMON)
        foreach(VER ${FILTERED_VERS})
            if(${VER} VERSION_LESS ${CUDA_VER})

                # Copy arch list and apply minimal filter
                set(TMP_ARCHS ${CUDA_ARCH_${VER}})
                list_filter(TMP_ARCHS "LESS;${ARG_ARCH_MIN}")

                # Append uncommon arch
                list(LENGTH TMP_ARCHS TMP_ARCHS_LEN)
                if(${TMP_ARCHS_LEN} GREATER 0)
                    foreach(CUDA_ARCH ${CUDA_ARCH_UNION})
                        if(NOT ${CUDA_ARCH} IN_LIST TMP_ARCHS)
                            list(APPEND CUDA_ARCH_UNCOMMON ${CUDA_ARCH})
                        endif()
                    endforeach()
                endif()

            endif()
        endforeach()

        list(REMOVE_DUPLICATES CUDA_ARCH_UNCOMMON)
        list(SORT CUDA_ARCH_UNCOMMON)
        debug_info("Found uncommon cuda architectures: ${CUDA_ARCH_UNCOMMON}")

        # Remove uncommon CUDA architectures
        list(REMOVE_ITEM CUDA_ARCH_UNION ${CUDA_ARCH_UNCOMMON})
        debug_info("List after removing uncommon arch: ${CUDA_ARCH_UNION}")

        # Apply result
        set(CUDA_ARCH_LIST ${CUDA_ARCH_UNION})

    endif()

    # Return architecture list
    set(${ARG_OUTPUT_VARIABLE} ${CUDA_ARCH_LIST} PARENT_SCOPE)
    debug_info("Final arch list: ${CUDA_ARCH_LIST}")

endfunction()

macro(DEBUG_INFO)
    if(${ARG_VERBOSE})
        message("[CUDAHelper] ${ARGN}")
    endif()
endmacro()

macro(LIST_FILTER SOURCE RM_COND)
    foreach(ITEM ${${SOURCE}})
        if(${ITEM} ${RM_COND})
            list(REMOVE_ITEM ${SOURCE} ${ITEM})
        endif()
    endforeach()
endmacro()
