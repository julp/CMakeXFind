#
# This module is designed to find VarnishAPI and build Varnish modules (VMOD)
#
# Requirements:
# - CMake >= 2.8.3 (for new version of find_package_handle_standard_args)
#
# The following variables will be defined for your use:
#   - VARNISHAPI_VERSION        : complete version of varnish (x.y.z)
#   - VARNISHAPI_MAJOR_VERSION  : major version of varnish
#   - VARNISHAPI_MINOR_VERSION  : minor version of varnish
#   - VARNISHAPI_PATCH_VERSION  : patch version of varnish
#   - VARNISHAPI_VERSION_NUMBER : a version number as 1000 * VARNISHAPI_MAJOR_VERSION + 100 * VARNISHAPI_MINOR_VERSION + VARNISHAPI_PATCH_VERSION
#
# Additional variables exported you probably don't need:
#   - VARNISHAPI_VMODDIR       : directory from which Varnish loads its VMODs
#   - VARNISHAPI_VMODTOOL      : path of the script vmodtool.py
#   - VARNISHAPI_PKGINCLUDEDIR : include directory to varnish headers needed by vmod
#
# The following macro is provided:
#   declare_vmod
#
# Prototype:
#   declare_vmod([INSTALL] [NAME <name>] [VCC <vcc>] [ADDITIONNAL_INCLUDE_DIRECTORIES <list of extra include directories>] [ADDITIONNAL_LIBRARIES <list of extra libraries>] [SOURCES <list of files>])
#
#  Argument details:
#    - INSTALL (optionnal):                                             if present, add vmod to install target
#    - NAME <name> (mandatory):                                         vmod's name (used to name cmake internal library and target)
#    - VCC <input> (mandatory):                                         the VCC spec file which describes the module
#    - SOURCES <file1> ... <file2> (mandatory):                         list of source (C) files
#    - ADDITIONNAL_LIBRARIES <file1> ... <file2> (optionnal):           a list of extra libraries to link on
#    - ADDITIONNAL_INCLUDE_DIRECTORIES <file1> ... <file2> (optionnal): a list of extra include directories
#
# How to use:
#   1) Copy this file in the root of your project source directory
#   2) Then, tell CMake to search this non-standard module in your project directory by adding to your CMakeLists.txt:
#        set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#   3) Finally call find_package(VarnishAPI) once
#
# Here is a complete sample to build sqlite3 VMOD (https://github.com/fgsch/libvmod-sqlite3) with cmake:
#
#   set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#
#   find_package(SQLite3 REQUIRED)
#   find_package(VarnishAPI REQUIRED) # Note: name is case sensitive
#
#   declare_vmod(
#       INSTALL
#       NAME sqlite
#       VCC ${PROJECT_SOURCE_DIR}/vmod_sqlite.vcc
#       SOURCES ${PROJECT_SOURCE_DIR}/vmod_sqlite.c
#       ADDITIONNAL_LIBRARIES ${SQLITE3_LIBRARIES}
#       ADDITIONNAL_INCLUDE_DIRECTORIES ${SQLITE3_INCLUDE_DIRS}
#   )
#
# A minimal version can be required, example for Varnish 4.0:
#
#   find_package(VarnishAPI 4.0 REQUIRED)
#

#=============================================================================
# Copyright (c) 2015, julp
#
# Distributed under the OSI-approved BSD License
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#=============================================================================

cmake_minimum_required(VERSION 2.8.3)

########## Private ##########
if(NOT DEFINED VARNISHAPI_PUBLIC_VAR_NS)
    set(VARNISHAPI_PUBLIC_VAR_NS "VARNISHAPI")
endif(NOT DEFINED VARNISHAPI_PUBLIC_VAR_NS)
if(NOT DEFINED VARNISHAPI_PRIVATE_VAR_NS)
    set(VARNISHAPI_PRIVATE_VAR_NS "_${VARNISHAPI_PUBLIC_VAR_NS}")
endif(NOT DEFINED VARNISHAPI_PRIVATE_VAR_NS)

function(varnish_debug _VARNAME)
    if(${VARNISHAPI_PUBLIC_VAR_NS}_DEBUG)
        if(DEFINED ${VARNISHAPI_PUBLIC_VAR_NS}_${_VARNAME})
            message("${VARNISHAPI_PUBLIC_VAR_NS}_${_VARNAME} = ${${VARNISHAPI_PUBLIC_VAR_NS}_${_VARNAME}}")
        else(DEFINED ${VARNISHAPI_PUBLIC_VAR_NS}_${_VARNAME})
            message("${VARNISHAPI_PUBLIC_VAR_NS}_${_VARNAME} = <UNDEFINED>")
        endif(DEFINED ${VARNISHAPI_PUBLIC_VAR_NS}_${_VARNAME})
    endif(${VARNISHAPI_PUBLIC_VAR_NS}_DEBUG)
endfunction(varnish_debug)

# Alias all VarnishAPI_FIND_X variables to VARNISHAPI_FIND_X
# Workaround for find_package: no way to force case of variable's names it creates (I don't want to change MY coding standard)
set(${VARNISHAPI_PRIVATE_VAR_NS}_FIND_PKG_PREFIX "VarnishAPI")
get_directory_property(${VARNISHAPI_PRIVATE_VAR_NS}_CURRENT_VARIABLES VARIABLES)
foreach(${VARNISHAPI_PRIVATE_VAR_NS}_VARNAME ${${VARNISHAPI_PRIVATE_VAR_NS}_CURRENT_VARIABLES})
    if(${VARNISHAPI_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${VARNISHAPI_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
        string(REGEX REPLACE "^${${VARNISHAPI_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}" "${VARNISHAPI_PUBLIC_VAR_NS}" ${VARNISHAPI_PRIVATE_VAR_NS}_NORMALIZED_VARNAME ${${VARNISHAPI_PRIVATE_VAR_NS}_VARNAME})
        set(${${VARNISHAPI_PRIVATE_VAR_NS}_NORMALIZED_VARNAME} ${${${VARNISHAPI_PRIVATE_VAR_NS}_VARNAME}})
    endif(${VARNISHAPI_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${VARNISHAPI_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
endforeach(${VARNISHAPI_PRIVATE_VAR_NS}_VARNAME)

# not needed since varnish 4?
# if(NOT DEFINED ${VARNISHAPI_PUBLIC_VAR_NS}_SOURCE_DIR)
#     message(WARNING "You may need to add -D${VARNISHAPI_PUBLIC_VAR_NS}_SOURCE_DIR:PATH=/path/to/varnish/sources to your cmake command line or define it through its GUI (ccmake & co)")
# endif(NOT DEFINED ${VARNISHAPI_PUBLIC_VAR_NS}_SOURCE_DIR)

find_package(PkgConfig REQUIRED)
find_package(PythonInterp REQUIRED)

# bash -c 'for var in `pkg-config --print-variables varnishapi`; do echo -n "${var} : "; pkg-config --variable=${var} varnishapi; done'
set(${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_NAME "varnishapi")
set(${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX "${VARNISHAPI_PRIVATE_VAR_NS}_PKG_CHECK_VAR")
set(${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VARNAMES_TO_EXPORT vmoddir pkgincludedir vmodtool)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX} ${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_NAME} REQUIRED)
    if(${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX}_FOUND)
        foreach(${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VARNAME ${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VARNAMES_TO_EXPORT})
            execute_process(
                COMMAND ${PKG_CONFIG_EXECUTABLE} ${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_NAME} --variable=${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VARNAME}
                OUTPUT_VARIABLE ${VARNISHAPI_PRIVATE_VAR_NS}_PKG_OUTPUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
                RESULT_VARIABLE ${VARNISHAPI_PRIVATE_VAR_NS}_PKG_RESULT_VAR
            )
            if(${VARNISHAPI_PRIVATE_VAR_NS}_PKG_RESULT_VAR)
                message(FATAL_ERROR "pkg-config variable ${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VARNAME} not found for ${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_NAME}")
            endif(${VARNISHAPI_PRIVATE_VAR_NS}_PKG_RESULT_VAR)
            string(TOUPPER ${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VARNAME} ${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_UPPER_VARNAME)
            set(${VARNISHAPI_PUBLIC_VAR_NS}_${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_UPPER_VARNAME} ${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_OUTPUT_VAR})
        endforeach(${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VARNAME)
        # NOTE: ${VARNISHAPI_PRIVATE_VAR_NS}_VARNISHAPI_VERSION is created by PkgConfig (this is the result of pkg-config --modversion varnishapi)
        if(${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX}_VERSION)
            # "alias" it as VARNISHAPI_VERSION for consistency
            set(${VARNISHAPI_PUBLIC_VAR_NS}_VERSION "${${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX}_VERSION}")
            unset(${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX}_VERSION)
            # extract major/minor/patch parts
            string(REGEX MATCHALL "[0-9]+" ${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_PARTS ${${VARNISHAPI_PUBLIC_VAR_NS}_VERSION})
            list(GET ${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_PARTS 0 ${VARNISHAPI_PUBLIC_VAR_NS}_MAJOR_VERSION)
            list(GET ${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_PARTS 1 ${VARNISHAPI_PUBLIC_VAR_NS}_MINOR_VERSION)
            list(GET ${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_PARTS 2 ${VARNISHAPI_PUBLIC_VAR_NS}_PATCH_VERSION)
            # build a version number
            math(EXPR ${VARNISHAPI_PUBLIC_VAR_NS}_VERSION_NUMBER "${${VARNISHAPI_PUBLIC_VAR_NS}_MAJOR_VERSION} * 1000 + ${${VARNISHAPI_PUBLIC_VAR_NS}_MINOR_VERSION} * 100 + ${${VARNISHAPI_PUBLIC_VAR_NS}_PATCH_VERSION}")
        endif(${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX}_VERSION)
    else(${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX}_FOUND)
        message(FATAL_ERROR "there is no module named \"varnishapi\" registered by pkg-config")
    endif(${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_VAR_PREFIX}_FOUND)
endif(PKG_CONFIG_FOUND)

# if(EXISTS "${${VARNISHAPI_PUBLIC_VAR_NS}_PKGINCLUDEDIR}/vmod_abi.h")
#     file(READ "${${VARNISHAPI_PUBLIC_VAR_NS}_PKGINCLUDEDIR}/vmod_abi.h" ${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_HEADER_CONTENTS)
#     if(${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_HEADER_CONTENTS MATCHES ".*# *define *VMOD_ABI_Version *\"Varnish *([0-9.]+) *[a-f0-9]*\".*")
#         set(${VARNISHAPI_PUBLIC_VAR_NS}_VERSION ${CMAKE_MATCH_1})
#     else(${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_HEADER_CONTENTS MATCHES ".*# *define *VMOD_ABI_Version *\"Varnish *([0-9.]+) *[a-f0-9]*\".*")
#         message(WARNING "unknown format found in varnish include files, please report")
#     endif(${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_HEADER_CONTENTS MATCHES ".*# *define *VMOD_ABI_Version *\"Varnish *([0-9.]+) *[a-f0-9]*\".*")
# endif(EXISTS "${${VARNISHAPI_PUBLIC_VAR_NS}_PKGINCLUDEDIR}/vmod_abi.h")
# 
# if(NOT ${VARNISHAPI_PUBLIC_VAR_NS}_VERSION)
#     find_program(${VARNISHAPI_PUBLIC_VAR_NS}_VARNISHD_EXECUTABLE varnishd)
#     if(${VARNISHAPI_PUBLIC_VAR_NS}_VARNISHD_EXECUTABLE)
#         execute_process(COMMAND ${${VARNISHAPI_PUBLIC_VAR_NS}_VARNISHD_EXECUTABLE} -V ERROR_VARIABLE ${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_OUTPUT ERROR_STRIP_TRAILING_WHITESPACE)
#         if(${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_OUTPUT MATCHES "varnishd \\(varnish-([0-9.]+) revision [a-f0-9]+\\)")
#             set(${VARNISHAPI_PUBLIC_VAR_NS}_VERSION ${CMAKE_MATCH_1})
#         else(${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_OUTPUT MATCHES "varnishd \\(varnish-([0-9.]+) revision [a-f0-9]+\\)")
#             message(WARNING "unknown format found in varnishd -V output, please report")
#         endif(${VARNISHAPI_PRIVATE_VAR_NS}_VERSION_OUTPUT MATCHES "varnishd \\(varnish-([0-9.]+) revision [a-f0-9]+\\)")
#     else(${VARNISHAPI_PUBLIC_VAR_NS}_VARNISHD_EXECUTABLE)
#         message(FATAL_ERROR "varnishd was not found")
#     endif(${VARNISHAPI_PUBLIC_VAR_NS}_VARNISHD_EXECUTABLE)
# endif(NOT ${VARNISHAPI_PUBLIC_VAR_NS}_VERSION)

include(FindPackageHandleStandardArgs)
if(${VARNISHAPI_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${VARNISHAPI_PUBLIC_VAR_NS}_FIND_QUIETLY)
    find_package_handle_standard_args(
        ${VARNISHAPI_PUBLIC_VAR_NS}
        REQUIRED_VARS ${VARNISHAPI_PUBLIC_VAR_NS}_VMODTOOL ${VARNISHAPI_PUBLIC_VAR_NS}_VMODDIR ${VARNISHAPI_PUBLIC_VAR_NS}_PKGINCLUDEDIR
        VERSION_VAR ${VARNISHAPI_PUBLIC_VAR_NS}_VERSION
    )
else(${VARNISHAPI_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${VARNISHAPI_PUBLIC_VAR_NS}_FIND_QUIETLY)
    find_package_handle_standard_args(${VARNISHAPI_PUBLIC_VAR_NS} "${${VARNISHAPI_PRIVATE_VAR_NS}_PKG_VARNISHAPI_NAME} not found" ${VARNISHAPI_PUBLIC_VAR_NS}_VMODTOOL)
endif(${VARNISHAPI_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${VARNISHAPI_PUBLIC_VAR_NS}_FIND_QUIETLY)

macro(declare_vmod)
    cmake_parse_arguments(VMOD "INSTALL" "NAME;VCC" "ADDITIONNAL_INCLUDE_DIRECTORIES;ADDITIONNAL_LIBRARIES;SOURCES" ${ARGN})

    if(NOT VMOD_NAME)
        message(FATAL_ERROR "declare_vmod, missing expected argument: NAME")
    endif(NOT VMOD_NAME)
    if(NOT VMOD_SOURCES)
        message(FATAL_ERROR "declare_vmod, missing expected argument: SOURCES")
    endif(NOT VMOD_SOURCES)
    add_custom_command(
        OUTPUT "${PROJECT_BINARY_DIR}/vcc_if.c" "${PROJECT_BINARY_DIR}/vcc_if.h"
        COMMAND ${PYTHON_EXECUTABLE} ${${VARNISHAPI_PUBLIC_VAR_NS}_VMODTOOL} ${VMOD_VCC}
        DEPENDS ${VMOD_VCC}
    )
#     add_custom_target(
#         "${VMOD_NAME}_vcc_if" ALL
#         COMMENT "vcc_if.[ch]"
#         DEPENDS vcc_if.h vcc_if.c
#     )
#     add_dependencies(${VMOD_NAME} "${VMOD_NAME}_vcc_if")
    list(APPEND VMOD_SOURCES "${PROJECT_BINARY_DIR}/vcc_if.c")
    list(APPEND VMOD_SOURCES "${PROJECT_BINARY_DIR}/vcc_if.h")
    add_library(${VMOD_NAME} SHARED ${VMOD_SOURCES})
    if(VMOD_ADDITIONNAL_LIBRARIES)
        target_link_libraries(${VMOD_NAME} ${VMOD_ADDITIONNAL_LIBRARIES})
    endif(VMOD_ADDITIONNAL_LIBRARIES)
    set(VMOD_INCLUDE_DIRECTORIES )
    list(APPEND VMOD_INCLUDE_DIRECTORIES ${PROJECT_SOURCE_DIR})
    list(APPEND VMOD_INCLUDE_DIRECTORIES ${PROJECT_BINARY_DIR})
#     if(DEFINED ${VARNISHAPI_PUBLIC_VAR_NS}_SOURCE_DIR)
#         list(APPEND VMOD_INCLUDE_DIRECTORIES "${${VARNISHAPI_PUBLIC_VAR_NS}_SOURCE_DIR}/include")
#     endif(DEFINED ${VARNISHAPI_PUBLIC_VAR_NS}_SOURCE_DIR)
    list(APPEND VMOD_INCLUDE_DIRECTORIES ${${VARNISHAPI_PUBLIC_VAR_NS}_PKGINCLUDEDIR})
    list(APPEND VMOD_INCLUDE_DIRECTORIES ${VMOD_ADDITIONNAL_INCLUDE_DIRECTORIES})
    set_target_properties(${VMOD_NAME} PROPERTIES
        COMPILE_DEFINITIONS "VARNISH_MAJOR=${${VARNISHAPI_PUBLIC_VAR_NS}_MAJOR_VERSION};VARNISH_MINOR=${${VARNISHAPI_PUBLIC_VAR_NS}_MINOR_VERSION};VARNISH_PATCH=${${VARNISHAPI_PUBLIC_VAR_NS}_PATCH_VERSION};VARNISH_VERNUM=${${VARNISHAPI_PUBLIC_VAR_NS}_VERSION_NUMBER}"
        INCLUDE_DIRECTORIES "${VMOD_INCLUDE_DIRECTORIES}"
        PREFIX "libvmod_"
    )
    get_target_property(VAR ${VMOD_NAME} INCLUDE_DIRECTORIES)
    if(VMOD_INSTALL)
        install(TARGETS ${VMOD_NAME} DESTINATION ${${VARNISHAPI_PUBLIC_VAR_NS}_VMODDIR})
    endif(VMOD_INSTALL)
endmacro(declare_vmod)

# IN (args)
varnish_debug("FIND_REQUIRED")
varnish_debug("FIND_QUIETLY")
varnish_debug("FIND_VERSION")
# OUT
varnish_debug("FOUND")
varnish_debug("VERSION")
varnish_debug("MAJOR_VERSION")
varnish_debug("MINOR_VERSION")
varnish_debug("PATCH_VERSION")
varnish_debug("VMODDIR")
varnish_debug("VMODTOOL")
varnish_debug("PKGINCLUDEDIR")
