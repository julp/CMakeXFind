#
# This module is designed to find/handle mysql library
#
# Requirements:
# - CMake >= 2.8.3 (for new version of find_package_handle_standard_args)
#
# The following variables will be defined for your use:
#   - MYSQL_INCLUDE_DIRS  : mysql include directory
#   - MYSQL_LIBRARIES     : mysql libraries
#   - MYSQL_VERSION       : complete version of mysql (x.y.z)
#   - MYSQL_MAJOR_VERSION : major version of mysql
#   - MYSQL_MINOR_VERSION : minor version of mysql
#   - MYSQL_PATCH_VERSION : patch version of mysql
#
# How to use:
#   1) Copy this file in the root of your project source directory
#   2) Then, tell CMake to search this non-standard module in your project directory by adding to your CMakeLists.txt:
#        set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#   3) Finally call find_package(MySQL) once
#
# Here is a complete sample to build an executable:
#
#   set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#
#   find_package(MySQL REQUIRED) # Note: name is case sensitive
#
#   include_directories(${MYSQL_INCLUDE_DIRS})
#   add_executable(myapp myapp.c)
#   target_link_libraries(myapp ${MYSQL_LIBRARIES})
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
if(NOT DEFINED MYSQL_PUBLIC_VAR_NS)
    set(MYSQL_PUBLIC_VAR_NS "MYSQL")
endif(NOT DEFINED MYSQL_PUBLIC_VAR_NS)
if(NOT DEFINED MYSQL_PRIVATE_VAR_NS)
    set(MYSQL_PRIVATE_VAR_NS "_${MYSQL_PUBLIC_VAR_NS}")
endif(NOT DEFINED MYSQL_PRIVATE_VAR_NS)

function(mysql_debug _VARNAME)
    if(${MYSQL_PUBLIC_VAR_NS}_DEBUG)
        if(DEFINED ${MYSQL_PUBLIC_VAR_NS}_${_VARNAME})
            message("${MYSQL_PUBLIC_VAR_NS}_${_VARNAME} = ${${MYSQL_PUBLIC_VAR_NS}_${_VARNAME}}")
        else(DEFINED ${MYSQL_PUBLIC_VAR_NS}_${_VARNAME})
            message("${MYSQL_PUBLIC_VAR_NS}_${_VARNAME} = <UNDEFINED>")
        endif(DEFINED ${MYSQL_PUBLIC_VAR_NS}_${_VARNAME})
    endif(${MYSQL_PUBLIC_VAR_NS}_DEBUG)
endfunction(mysql_debug)

# Alias all MySQL_FIND_X variables to MYSQL_FIND_X
# Workaround for find_package: no way to force case of variable's names it creates (I don't want to change MY coding standard)
set(${MYSQL_PRIVATE_VAR_NS}_FIND_PKG_PREFIX "MySQL")
get_directory_property(${MYSQL_PRIVATE_VAR_NS}_CURRENT_VARIABLES VARIABLES)
foreach(${MYSQL_PRIVATE_VAR_NS}_VARNAME ${${MYSQL_PRIVATE_VAR_NS}_CURRENT_VARIABLES})
    if(${MYSQL_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${MYSQL_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
        string(REGEX REPLACE "^${${MYSQL_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}" "${MYSQL_PUBLIC_VAR_NS}" ${MYSQL_PRIVATE_VAR_NS}_NORMALIZED_VARNAME ${${MYSQL_PRIVATE_VAR_NS}_VARNAME})
        set(${${MYSQL_PRIVATE_VAR_NS}_NORMALIZED_VARNAME} ${${${MYSQL_PRIVATE_VAR_NS}_VARNAME}})
    endif(${MYSQL_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${MYSQL_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
endforeach(${MYSQL_PRIVATE_VAR_NS}_VARNAME)

########## Public ##########
# find_program(${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE mysql_config)
if(${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE)
    execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --cflags                 OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_C_FLAGS)
    execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --include                OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS)
    execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --libs                   OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_LIBRARIES)
    execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --libs_r                 OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_LIBRARIES_R)
    execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --plugindir              OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_PLUGIN_DIR)
    execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --version                OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_VERSION)
#     execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --socket                 OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_SOCKET)
#     execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --port                   OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_PORT)
#     execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --libmysqld-libs         OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_LIBRARIES_EMBEDDED)
#     execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --variable=pkgincludedir OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_)
#     execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --variable=pkglibdir     OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_)
#     execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE} --variable=plugindir     OUTPUT_VARIABLE ${MYSQL_PUBLIC_VAR_NS}_)

    string(REGEX MATCHALL "[0-9]+" ${MYSQL_PRIVATE_VAR_NS}_VERSION_PARTS ${${MYSQL_PUBLIC_VAR_NS}_VERSION})
    list(GET ${MYSQL_PRIVATE_VAR_NS}_VERSION_PARTS 0 ${MYSQL_PUBLIC_VAR_NS}_MAJOR_VERSION)
    list(GET ${MYSQL_PRIVATE_VAR_NS}_VERSION_PARTS 1 ${MYSQL_PUBLIC_VAR_NS}_MINOR_VERSION)
    list(GET ${MYSQL_PRIVATE_VAR_NS}_VERSION_PARTS 2 ${MYSQL_PUBLIC_VAR_NS}_PATCH_VERSION)
else(${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE)
    find_path(
        ${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS
        NAMES mysql_version.h
        PATH_SUFFIXES include mysql
    )

    if(${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS)

        find_library(
            ${MYSQL_PUBLIC_VAR_NS}_LIBRARIES
            NAMES mysqlclient mysql
        )

        file(STRINGS "${${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS}/mysql_version.h" ${MYSQL_PRIVATE_VAR_NS}_VERSION_NUMBER_DEFINITION LIMIT_COUNT 1 REGEX ".*#[ \t]*define[ \t]*MYSQL_VERSION_ID[ \t]*[0-9]+.*")
        string(REGEX REPLACE ".*# *define +MYSQL_VERSION_ID +([0-9]+).*" "\\1" ${MYSQL_PRIVATE_VAR_NS}_VERSION_NUMBER ${${MYSQL_PRIVATE_VAR_NS}_VERSION_NUMBER_DEFINITION})

        math(EXPR ${MYSQL_PUBLIC_VAR_NS}_MAJOR_VERSION "${${MYSQL_PRIVATE_VAR_NS}_VERSION_NUMBER} / 10000")
        math(EXPR ${MYSQL_PUBLIC_VAR_NS}_MINOR_VERSION "(${${MYSQL_PRIVATE_VAR_NS}_VERSION_NUMBER} - ${${MYSQL_PUBLIC_VAR_NS}_MAJOR_VERSION} * 10000) / 100")
        math(EXPR ${MYSQL_PUBLIC_VAR_NS}_PATCH_VERSION "${${MYSQL_PRIVATE_VAR_NS}_VERSION_NUMBER} - ${${MYSQL_PUBLIC_VAR_NS}_MAJOR_VERSION} * 10000 - ${${MYSQL_PUBLIC_VAR_NS}_MINOR_VERSION} * 100")
        set(${MYSQL_PUBLIC_VAR_NS}_VERSION "${${MYSQL_PUBLIC_VAR_NS}_MAJOR_VERSION}.${${MYSQL_PUBLIC_VAR_NS}_MINOR_VERSION}.${${MYSQL_PUBLIC_VAR_NS}_PATCH_VERSION}")

        include(FindPackageHandleStandardArgs)
        if(${MYSQL_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${MYSQL_PUBLIC_VAR_NS}_FIND_QUIETLY)
            find_package_handle_standard_args(
                ${MYSQL_PUBLIC_VAR_NS}
                REQUIRED_VARS ${MYSQL_PUBLIC_VAR_NS}_LIBRARIES ${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS
                VERSION_VAR ${MYSQL_PUBLIC_VAR_NS}_VERSION
            )
        else(${MYSQL_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${MYSQL_PUBLIC_VAR_NS}_FIND_QUIETLY)
            find_package_handle_standard_args(${MYSQL_PUBLIC_VAR_NS} "sqlite3 not found" ${MYSQL_PUBLIC_VAR_NS}_LIBRARIES ${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS)
        endif(${MYSQL_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${MYSQL_PUBLIC_VAR_NS}_FIND_QUIETLY)

    else(${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS)

        if(${MYSQL_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${MYSQL_PUBLIC_VAR_NS}_FIND_QUIETLY)
            message(FATAL_ERROR "Could not find sqlite3 include directory")
        endif(${MYSQL_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${MYSQL_PUBLIC_VAR_NS}_FIND_QUIETLY)

    endif(${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS)
endif(${MYSQL_PUBLIC_VAR_NS}_CONFIG_EXECUTABLE)

mark_as_advanced(
    ${MYSQL_PUBLIC_VAR_NS}_INCLUDE_DIRS
    ${MYSQL_PUBLIC_VAR_NS}_LIBRARIES
)

# IN (args)
mysql_debug("FIND_REQUIRED")
mysql_debug("FIND_QUIETLY")
mysql_debug("FIND_VERSION")
# OUT
# Linking
mysql_debug("INCLUDE_DIRS")
mysql_debug("LIBRARIES")
# Version
mysql_debug("MAJOR_VERSION")
mysql_debug("MINOR_VERSION")
mysql_debug("PATCH_VERSION")
mysql_debug("VERSION")
