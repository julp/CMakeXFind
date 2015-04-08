#
# This module is designed to find/handle libgit2 library
#
# Requirements:
# - CMake >= 2.8.3 (for new version of find_package_handle_standard_args)
#
# The following variables will be defined for your use:
#   - GIT2_INCLUDE_DIRS     : libgit2 include directory
#   - GIT2_LIBRARIES        : libgit2 libraries
#   - GIT2_VERSION          : complete version of libgit2 (x.y.z)
#   - GIT2_MAJOR_VERSION    : major version of libgit2
#   - GIT2_MINOR_VERSION    : minor version of libgit2
#   - GIT2_REVISION_VERSION : revision version of libgit2
#
# How to use:
#   1) Copy this file in the root of your project source directory
#   2) Then, tell CMake to search this non-standard module in your project directory by adding to your CMakeLists.txt:
#        set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#   3) Finally call find_package(GIT2) once
#
# Here is a complete sample to build an executable:
#
#   set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#
#   find_package(GIT2 REQUIRED) # Note: name is case sensitive
#
#   include_directories(${GIT2_INCLUDE_DIRS})
#   add_executable(myapp myapp.c)
#   target_link_libraries(myapp ${GIT2_LIBRARIES})
#


#=============================================================================
# Copyright (c) 2013, julp
#
# Distributed under the OSI-approved BSD License
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#=============================================================================

cmake_minimum_required(VERSION 2.8.3)

########## Private ##########
if(NOT DEFINED GIT2_PUBLIC_VAR_NS)
    set(GIT2_PUBLIC_VAR_NS "GIT2")
endif(NOT DEFINED GIT2_PUBLIC_VAR_NS)
if(NOT DEFINED GIT2_PRIVATE_VAR_NS)
    set(GIT2_PRIVATE_VAR_NS "_${GIT2_PUBLIC_VAR_NS}")
endif(NOT DEFINED GIT2_PRIVATE_VAR_NS)

function(git2_debug _VARNAME)
    if(${GIT2_PUBLIC_VAR_NS}_DEBUG)
        if(DEFINED ${GIT2_PUBLIC_VAR_NS}_${_VARNAME})
            message("${GIT2_PUBLIC_VAR_NS}_${_VARNAME} = ${${GIT2_PUBLIC_VAR_NS}_${_VARNAME}}")
        else(DEFINED ${GIT2_PUBLIC_VAR_NS}_${_VARNAME})
            message("${GIT2_PUBLIC_VAR_NS}_${_VARNAME} = <UNDEFINED>")
        endif(DEFINED ${GIT2_PUBLIC_VAR_NS}_${_VARNAME})
    endif(${GIT2_PUBLIC_VAR_NS}_DEBUG)
endfunction(git2_debug)

########## Public ##########
find_path(
    ${GIT2_PUBLIC_VAR_NS}_INCLUDE_DIRS
    NAMES git2.h
    PATH_SUFFIXES "include"
)

if(${GIT2_PUBLIC_VAR_NS}_INCLUDE_DIRS)

    find_library(
        ${GIT2_PUBLIC_VAR_NS}_LIBRARIES
        NAMES git2
    )

    file(READ "${${GIT2_PUBLIC_VAR_NS}_INCLUDE_DIRS}/git2/version.h" ${GIT2_PRIVATE_VAR_NS}_H_CONTENT)
    string(REGEX REPLACE ".*# *define +LIBGIT2_VER_MAJOR +([0-9]+).*" "\\1" ${GIT2_PUBLIC_VAR_NS}_MAJOR_VERSION ${${GIT2_PRIVATE_VAR_NS}_H_CONTENT})
    string(REGEX REPLACE ".*# *define +LIBGIT2_VER_MINOR +([0-9]+).*" "\\1" ${GIT2_PUBLIC_VAR_NS}_MINOR_VERSION ${${GIT2_PRIVATE_VAR_NS}_H_CONTENT})
    string(REGEX REPLACE ".*# *define +LIBGIT2_VER_REVISION +([0-9]+).*" "\\1" ${GIT2_PUBLIC_VAR_NS}_REVISION_VERSION ${${GIT2_PRIVATE_VAR_NS}_H_CONTENT})
    set(${GIT2_PUBLIC_VAR_NS}_VERSION "${${GIT2_PUBLIC_VAR_NS}_MAJOR_VERSION}.${${GIT2_PUBLIC_VAR_NS}_MINOR_VERSION}.${${GIT2_PUBLIC_VAR_NS}_REVISION_VERSION}")

    include(FindPackageHandleStandardArgs)
    if(${GIT2_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${GIT2_PUBLIC_VAR_NS}_FIND_QUIETLY)
        find_package_handle_standard_args(
            ${GIT2_PUBLIC_VAR_NS}
            REQUIRED_VARS ${GIT2_PUBLIC_VAR_NS}_LIBRARIES ${GIT2_PUBLIC_VAR_NS}_INCLUDE_DIRS
            VERSION_VAR ${GIT2_PUBLIC_VAR_NS}_VERSION
        )
    else(${GIT2_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${GIT2_PUBLIC_VAR_NS}_FIND_QUIETLY)
        find_package_handle_standard_args(${GIT2_PUBLIC_VAR_NS} "libgit2 not found" ${GIT2_PUBLIC_VAR_NS}_LIBRARIES ${GIT2_PUBLIC_VAR_NS}_INCLUDE_DIRS)
    endif(${GIT2_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${GIT2_PUBLIC_VAR_NS}_FIND_QUIETLY)

else(${GIT2_PUBLIC_VAR_NS}_INCLUDE_DIRS)

    if(${GIT2_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${GIT2_PUBLIC_VAR_NS}_FIND_QUIETLY)
        message(FATAL_ERROR "Could not find libgit2 include directory")
    endif(${GIT2_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${GIT2_PUBLIC_VAR_NS}_FIND_QUIETLY)

endif(${GIT2_PUBLIC_VAR_NS}_INCLUDE_DIRS)

mark_as_advanced(
    ${GIT2_PUBLIC_VAR_NS}_INCLUDE_DIRS
    ${GIT2_PUBLIC_VAR_NS}_LIBRARIES
)

# IN (args)
git2_debug("FIND_REQUIRED")
git2_debug("FIND_QUIETLY")
git2_debug("FIND_VERSION")
# OUT
# Linking
git2_debug("INCLUDE_DIRS")
git2_debug("LIBRARIES")
# Version
git2_debug("MAJOR_VERSION")
git2_debug("MINOR_VERSION")
git2_debug("REVISION_VERSION")
git2_debug("VERSION")
