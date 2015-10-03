#
# This module is designed to find/handle libmemcached library
#
# Requirements:
# - CMake >= 2.8.3 (for new version of find_package_handle_standard_args)
#
# The following variables will be defined for your use:
#   - LIBMEMCACHED_INCLUDE_DIRS  : libmemcached include directory
#   - LIBMEMCACHED_LIBRARIES     : libmemcached libraries
#   - LIBMEMCACHED_VERSION       : complete version of libmemcached (x.y.z)
#   - LIBMEMCACHED_MAJOR_VERSION : major version of libmemcached
#   - LIBMEMCACHED_MINOR_VERSION : minor version of libmemcached
#   - LIBMEMCACHED_PATCH_VERSION : patch version of libmemcached
#
# How to use:
#   1) Copy this file in the root of your project source directory
#   2) Then, tell CMake to search this non-standard module in your project directory by adding to your CMakeLists.txt:
#        set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#   3) Finally call find_package(libmemcached) once
#
# Here is a complete sample to build an executable:
#
#   set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#
#   find_package(libMemcached REQUIRED) # Note: name is case sensitive
#
#   include_directories(${LIBMEMCACHED_INCLUDE_DIRS})
#   add_executable(myapp myapp.c)
#   target_link_libraries(myapp ${LIBMEMCACHED_LIBRARIES})
#


#=============================================================================
# Copyright (c) 2014, julp
#
# Distributed under the OSI-approved BSD License
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#=============================================================================

cmake_minimum_required(VERSION 2.8.3)

########## Private ##########
if(NOT DEFINED LIBMEMCACHED_PUBLIC_VAR_NS)
    set(LIBMEMCACHED_PUBLIC_VAR_NS "LIBMEMCACHED")
endif(NOT DEFINED LIBMEMCACHED_PUBLIC_VAR_NS)
if(NOT DEFINED LIBMEMCACHED_PRIVATE_VAR_NS)
    set(LIBMEMCACHED_PRIVATE_VAR_NS "_${LIBMEMCACHED_PUBLIC_VAR_NS}")
endif(NOT DEFINED LIBMEMCACHED_PRIVATE_VAR_NS)

function(libmemcached_debug _VARNAME)
    if(${LIBMEMCACHED_PUBLIC_VAR_NS}_DEBUG)
        if(DEFINED ${LIBMEMCACHED_PUBLIC_VAR_NS}_${_VARNAME})
            message("${LIBMEMCACHED_PUBLIC_VAR_NS}_${_VARNAME} = ${${LIBMEMCACHED_PUBLIC_VAR_NS}_${_VARNAME}}")
        else(DEFINED ${LIBMEMCACHED_PUBLIC_VAR_NS}_${_VARNAME})
            message("${LIBMEMCACHED_PUBLIC_VAR_NS}_${_VARNAME} = <UNDEFINED>")
        endif(DEFINED ${LIBMEMCACHED_PUBLIC_VAR_NS}_${_VARNAME})
    endif(${LIBMEMCACHED_PUBLIC_VAR_NS}_DEBUG)
endfunction(libmemcached_debug)

# Alias all libMemcached_FIND_X variables to LIBMEMCACHED_FIND_X
# Workaround for find_package: no way to force case of variable's names it creates (I don't want to change MY coding standard)
# ---
# NOTE: only prefix is considered, not full name of the variables to minimize conflicts with string(TOUPPER) for example
# libMemcached_foo becomes LIBMEMCACHED_foo not libMemcached_FOO as this is two different variables
set(${LIBMEMCACHED_PRIVATE_VAR_NS}_FIND_PKG_PREFIX "libMemcached")
get_directory_property(${LIBMEMCACHED_PRIVATE_VAR_NS}_CURRENT_VARIABLES VARIABLES)
foreach(${LIBMEMCACHED_PRIVATE_VAR_NS}_VARNAME ${${LIBMEMCACHED_PRIVATE_VAR_NS}_CURRENT_VARIABLES})
    if(${LIBMEMCACHED_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${LIBMEMCACHED_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
        string(REGEX REPLACE "^${${LIBMEMCACHED_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}" "${LIBMEMCACHED_PUBLIC_VAR_NS}" ${LIBMEMCACHED_PRIVATE_VAR_NS}_NORMALIZED_VARNAME ${${LIBMEMCACHED_PRIVATE_VAR_NS}_VARNAME})
        set(${${LIBMEMCACHED_PRIVATE_VAR_NS}_NORMALIZED_VARNAME} ${${${LIBMEMCACHED_PRIVATE_VAR_NS}_VARNAME}})
    endif(${LIBMEMCACHED_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${LIBMEMCACHED_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
endforeach(${LIBMEMCACHED_PRIVATE_VAR_NS}_VARNAME)

########## Public ##########
find_path(
    ${LIBMEMCACHED_PUBLIC_VAR_NS}_INCLUDE_DIRS
    NAMES memcached.h
    PATH_SUFFIXES "libmemcached-1.0"
)

if(${LIBMEMCACHED_PUBLIC_VAR_NS}_INCLUDE_DIRS)

    find_library(
        ${LIBMEMCACHED_PUBLIC_VAR_NS}_LIBRARIES
        NAMES memcached
    )

    file(STRINGS "${${LIBMEMCACHED_PUBLIC_VAR_NS}_INCLUDE_DIRS}/configure.h" ${LIBMEMCACHED_PRIVATE_VAR_NS}_VERSION_STRING LIMIT_COUNT 1 REGEX "# *define +LIBMEMCACHED_VERSION_STRING *\"[0-9]+\\.[0-9]+\\.[0-9]+\"")
    string(REGEX REPLACE "# *define +LIBMEMCACHED_VERSION_STRING *\"([0-9.]+)\"" "\\1" ${LIBMEMCACHED_PUBLIC_VAR_NS}_VERSION ${${LIBMEMCACHED_PRIVATE_VAR_NS}_VERSION_STRING})
    string(REGEX MATCHALL "[0-9]+" ${LIBMEMCACHED_PRIVATE_VAR_NS}_VERSION_PARTS ${${LIBMEMCACHED_PUBLIC_VAR_NS}_VERSION})
    list(GET ${LIBMEMCACHED_PRIVATE_VAR_NS}_VERSION_PARTS 0 ${LIBMEMCACHED_PUBLIC_VAR_NS}_MAJOR_VERSION)
    list(GET ${LIBMEMCACHED_PRIVATE_VAR_NS}_VERSION_PARTS 1 ${LIBMEMCACHED_PUBLIC_VAR_NS}_MINOR_VERSION)
    list(GET ${LIBMEMCACHED_PRIVATE_VAR_NS}_VERSION_PARTS 2 ${LIBMEMCACHED_PUBLIC_VAR_NS}_PATCH_VERSION)

    include(FindPackageHandleStandardArgs)
    if(${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_QUIETLY)
        find_package_handle_standard_args(
            ${LIBMEMCACHED_PUBLIC_VAR_NS}
            REQUIRED_VARS ${LIBMEMCACHED_PUBLIC_VAR_NS}_LIBRARIES ${LIBMEMCACHED_PUBLIC_VAR_NS}_INCLUDE_DIRS
            VERSION_VAR ${LIBMEMCACHED_PUBLIC_VAR_NS}_VERSION
        )
    else(${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_QUIETLY)
        find_package_handle_standard_args(${LIBMEMCACHED_PUBLIC_VAR_NS} "libmemcached not found" ${LIBMEMCACHED_PUBLIC_VAR_NS}_LIBRARIES ${LIBMEMCACHED_PUBLIC_VAR_NS}_INCLUDE_DIRS)
    endif(${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_QUIETLY)

else(${LIBMEMCACHED_PUBLIC_VAR_NS}_INCLUDE_DIRS)

    if(${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_QUIETLY)
        message(FATAL_ERROR "Could not find libmemcached include directory")
    endif(${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${LIBMEMCACHED_PUBLIC_VAR_NS}_FIND_QUIETLY)

endif(${LIBMEMCACHED_PUBLIC_VAR_NS}_INCLUDE_DIRS)

mark_as_advanced(
    ${LIBMEMCACHED_PUBLIC_VAR_NS}_INCLUDE_DIRS
    ${LIBMEMCACHED_PUBLIC_VAR_NS}_LIBRARIES
)

# IN (args)
libmemcached_debug("FIND_REQUIRED")
libmemcached_debug("FIND_QUIETLY")
libmemcached_debug("FIND_VERSION")
# OUT
# Linking
libmemcached_debug("INCLUDE_DIRS")
libmemcached_debug("LIBRARIES")
# Version
libmemcached_debug("MAJOR_VERSION")
libmemcached_debug("MINOR_VERSION")
libmemcached_debug("PATCH_VERSION")
libmemcached_debug("VERSION")
