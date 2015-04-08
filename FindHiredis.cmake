#
# This module is designed to find/handle hiredis library
#
# Requirements:
# - CMake >= 2.8.3 (for new version of find_package_handle_standard_args)
#
# The following variables will be defined for your use:
#   - HIREDIS_INCLUDE_DIRS  : hiredis include directory
#   - HIREDIS_LIBRARIES     : hiredis libraries
#   - HIREDIS_VERSION       : complete version of hiredis (x.y.z)
#   - HIREDIS_MAJOR_VERSION : major version of hiredis
#   - HIREDIS_MINOR_VERSION : minor version of hiredis
#   - HIREDIS_PATCH_VERSION : patch version of hiredis
#
# How to use:
#   1) Copy this file in the root of your project source directory
#   2) Then, tell CMake to search this non-standard module in your project directory by adding to your CMakeLists.txt:
#        set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#   3) Finally call find_package(Hiredis) once
#
# Here is a complete sample to build an executable:
#
#   set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#
#   find_package(Hiredis REQUIRED) # Note: name is case sensitive
#
#   include_directories(${HIREDIS_INCLUDE_DIRS})
#   add_executable(myapp myapp.c)
#   target_link_libraries(myapp ${HIREDIS_LIBRARIES})
#


#=============================================================================
# Copyright (c) 2012, julp
#
# Distributed under the OSI-approved BSD License
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#=============================================================================

cmake_minimum_required(VERSION 2.8.3)

########## Private ##########
if(NOT DEFINED HIREDIS_PUBLIC_VAR_NS)
    set(HIREDIS_PUBLIC_VAR_NS "HIREDIS")
endif(NOT DEFINED HIREDIS_PUBLIC_VAR_NS)
if(NOT DEFINED HIREDIS_PRIVATE_VAR_NS)
    set(HIREDIS_PRIVATE_VAR_NS "_${HIREDIS_PUBLIC_VAR_NS}")
endif(NOT DEFINED HIREDIS_PRIVATE_VAR_NS)

function(hiredis_debug _VARNAME)
    if(${HIREDIS_PUBLIC_VAR_NS}_DEBUG)
        if(DEFINED ${HIREDIS_PUBLIC_VAR_NS}_${_VARNAME})
            message("${HIREDIS_PUBLIC_VAR_NS}_${_VARNAME} = ${${HIREDIS_PUBLIC_VAR_NS}_${_VARNAME}}")
        else(DEFINED ${HIREDIS_PUBLIC_VAR_NS}_${_VARNAME})
            message("${HIREDIS_PUBLIC_VAR_NS}_${_VARNAME} = <UNDEFINED>")
        endif(DEFINED ${HIREDIS_PUBLIC_VAR_NS}_${_VARNAME})
    endif(${HIREDIS_PUBLIC_VAR_NS}_DEBUG)
endfunction(hiredis_debug)

# Workaround for find_package: no way to force case of variable's names it creates (I don't want to change MY coding standard)
function(totitle _STRING _OUTPUT_VAR)
    string(SUBSTRING ${_STRING} 0  1 FIRST_CHAR)
    string(SUBSTRING ${_STRING} 1 -1 STRING_REST)
    string(TOLOWER ${STRING_REST} LOWCASE_STRING_REST)
    string(TOUPPER ${FIRST_CHAR} UPCASED_FIRST_CHAR)
    set(${_OUTPUT_VAR} "${UPCASED_FIRST_CHAR}${LOWCASE_STRING_REST}" PARENT_SCOPE)
endfunction(totitle)

totitle(${HIREDIS_PUBLIC_VAR_NS} ${HIREDIS_PRIVATE_VAR_NS}_FIND_PKG_PREFIX)
# Alias all Hiredis_FIND_X variables to HIREDIS_FIND_X
get_directory_property(${HIREDIS_PRIVATE_VAR_NS}_CURRENT_VARIABLES VARIABLES)
foreach(${HIREDIS_PRIVATE_VAR_NS}_VARNAME ${${HIREDIS_PRIVATE_VAR_NS}_CURRENT_VARIABLES})
    if(${HIREDIS_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${HIREDIS_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
        string(REGEX REPLACE "^${${HIREDIS_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}" "${HIREDIS_PUBLIC_VAR_NS}" ${HIREDIS_PRIVATE_VAR_NS}_NORMALIZED_VARNAME ${${HIREDIS_PRIVATE_VAR_NS}_VARNAME})
        set(${${HIREDIS_PRIVATE_VAR_NS}_NORMALIZED_VARNAME} ${${${HIREDIS_PRIVATE_VAR_NS}_VARNAME}})
    endif(${HIREDIS_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${HIREDIS_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
endforeach(${HIREDIS_PRIVATE_VAR_NS}_VARNAME)

########## Public ##########
find_path(
    ${HIREDIS_PUBLIC_VAR_NS}_INCLUDE_DIRS
    NAMES hiredis.h
    PATH_SUFFIXES "hiredis"
)

if(${HIREDIS_PUBLIC_VAR_NS}_INCLUDE_DIRS)

    find_library(
        ${HIREDIS_PUBLIC_VAR_NS}_LIBRARIES
        NAMES hiredis
    )

    file(READ "${${HIREDIS_PUBLIC_VAR_NS}_INCLUDE_DIRS}/hiredis.h" ${HIREDIS_PRIVATE_VAR_NS}_H_CONTENT)
    string(REGEX REPLACE ".*# *define +HIREDIS_MAJOR +([0-9]+).*" "\\1" ${HIREDIS_PUBLIC_VAR_NS}_MAJOR_VERSION ${${HIREDIS_PRIVATE_VAR_NS}_H_CONTENT})
    string(REGEX REPLACE ".*# *define +HIREDIS_MINOR +([0-9]+).*" "\\1" ${HIREDIS_PUBLIC_VAR_NS}_MINOR_VERSION ${${HIREDIS_PRIVATE_VAR_NS}_H_CONTENT})
    string(REGEX REPLACE ".*# *define +HIREDIS_PATCH +([0-9]+).*" "\\1" ${HIREDIS_PUBLIC_VAR_NS}_PATCH_VERSION ${${HIREDIS_PRIVATE_VAR_NS}_H_CONTENT})
    set(${HIREDIS_PUBLIC_VAR_NS}_VERSION "${${HIREDIS_PUBLIC_VAR_NS}_MAJOR_VERSION}.${${HIREDIS_PUBLIC_VAR_NS}_MINOR_VERSION}.${${HIREDIS_PUBLIC_VAR_NS}_PATCH_VERSION}")

    include(FindPackageHandleStandardArgs)
    if(${HIREDIS_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${HIREDIS_PUBLIC_VAR_NS}_FIND_QUIETLY)
        find_package_handle_standard_args(
            ${HIREDIS_PUBLIC_VAR_NS}
            REQUIRED_VARS ${HIREDIS_PUBLIC_VAR_NS}_LIBRARIES ${HIREDIS_PUBLIC_VAR_NS}_INCLUDE_DIRS
            VERSION_VAR ${HIREDIS_PUBLIC_VAR_NS}_VERSION
        )
    else(${HIREDIS_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${HIREDIS_PUBLIC_VAR_NS}_FIND_QUIETLY)
        find_package_handle_standard_args(${HIREDIS_PUBLIC_VAR_NS} "hiredis not found" ${HIREDIS_PUBLIC_VAR_NS}_LIBRARIES ${HIREDIS_PUBLIC_VAR_NS}_INCLUDE_DIRS)
    endif(${HIREDIS_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${HIREDIS_PUBLIC_VAR_NS}_FIND_QUIETLY)

else(${HIREDIS_PUBLIC_VAR_NS}_INCLUDE_DIRS)

    if(${HIREDIS_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${HIREDIS_PUBLIC_VAR_NS}_FIND_QUIETLY)
        message(FATAL_ERROR "Could not find hiredis include directory")
    endif(${HIREDIS_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${HIREDIS_PUBLIC_VAR_NS}_FIND_QUIETLY)

endif(${HIREDIS_PUBLIC_VAR_NS}_INCLUDE_DIRS)

mark_as_advanced(
    ${HIREDIS_PUBLIC_VAR_NS}_INCLUDE_DIRS
    ${HIREDIS_PUBLIC_VAR_NS}_LIBRARIES
)

# IN (args)
hiredis_debug("FIND_REQUIRED")
hiredis_debug("FIND_QUIETLY")
hiredis_debug("FIND_VERSION")
# OUT
# Linking
hiredis_debug("INCLUDE_DIRS")
hiredis_debug("LIBRARIES")
# Version
hiredis_debug("MAJOR_VERSION")
hiredis_debug("MINOR_VERSION")
hiredis_debug("PATCH_VERSION")
hiredis_debug("VERSION")
