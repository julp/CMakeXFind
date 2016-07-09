#
# This module is designed to find/handle sqlite3 library
#
# Requirements:
# - CMake >= 2.8.3 (for new version of find_package_handle_standard_args)
#
# The following variables will be defined for your use:
#   - SQLITE3_INCLUDE_DIRS  : sqlite3 include directory
#   - SQLITE3_LIBRARIES     : sqlite3 libraries
#   - SQLITE3_VERSION       : complete version of sqlite3 (x.y.z)
#   - SQLITE3_VERSION_MAJOR : major version of sqlite3
#   - SQLITE3_VERSION_MINOR : minor version of sqlite3
#   - SQLITE3_VERSION_PATCH : patch version of sqlite3
#
# How to use:
#   1) Copy this file in the root of your project source directory
#   2) Then, tell CMake to search this non-standard module in your project directory by adding to your CMakeLists.txt:
#        set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#   3) Finally call find_package(SQLite3) once
#
# Here is a complete sample to build an executable:
#
#   set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#
#   find_package(SQLite3 REQUIRED) # Note: name is case sensitive
#
#   add_executable(myapp myapp.c)
#   include_directories(${SQLITE3_INCLUDE_DIR})
#   target_link_libraries(myapp ${SQLITE3_LIBRARY})
#   # with CMake >= 3.0.0, the last two lines can be replaced by the following
#   target_link_libraries(myapp SQLite3::SQLite3) # Note: case also matters here
#


#=============================================================================
# Copyright (c) 2013-2016, julp
#
# Distributed under the OSI-approved BSD License
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#=============================================================================

cmake_minimum_required(VERSION 2.8.3)

find_package(PkgConfig QUIET)

########## Private ##########
if(NOT DEFINED SQLITE3_PUBLIC_VAR_NS)
    set(SQLITE3_PUBLIC_VAR_NS "SQLITE3")
endif(NOT DEFINED SQLITE3_PUBLIC_VAR_NS)
if(NOT DEFINED SQLITE3_PRIVATE_VAR_NS)
    set(SQLITE3_PRIVATE_VAR_NS "_${SQLITE3_PUBLIC_VAR_NS}")
endif(NOT DEFINED SQLITE3_PRIVATE_VAR_NS)
if(NOT DEFINED PC_SQLITE3_PRIVATE_VAR_NS)
    set(PC_SQLITE3_PRIVATE_VAR_NS "_PC${SQLITE3_PRIVATE_VAR_NS}")
endif(NOT DEFINED PC_SQLITE3_PRIVATE_VAR_NS)

# Alias all SQLite3_FIND_X variables to SQLITE3_FIND_X
# Workaround for find_package: no way to force case of variable's names it creates (I don't want to change MY coding standard)
set(${SQLITE3_PRIVATE_VAR_NS}_FIND_PKG_PREFIX "SQLite3")
get_directory_property(${SQLITE3_PRIVATE_VAR_NS}_CURRENT_VARIABLES VARIABLES)
foreach(${SQLITE3_PRIVATE_VAR_NS}_VARNAME ${${SQLITE3_PRIVATE_VAR_NS}_CURRENT_VARIABLES})
    if(${SQLITE3_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${SQLITE3_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
        string(REGEX REPLACE "^${${SQLITE3_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}" "${SQLITE3_PUBLIC_VAR_NS}" ${SQLITE3_PRIVATE_VAR_NS}_NORMALIZED_VARNAME ${${SQLITE3_PRIVATE_VAR_NS}_VARNAME})
        set(${${SQLITE3_PRIVATE_VAR_NS}_NORMALIZED_VARNAME} ${${${SQLITE3_PRIVATE_VAR_NS}_VARNAME}})
    endif(${SQLITE3_PRIVATE_VAR_NS}_VARNAME MATCHES "^${${SQLITE3_PRIVATE_VAR_NS}_FIND_PKG_PREFIX}")
endforeach(${SQLITE3_PRIVATE_VAR_NS}_VARNAME)

########## Public ##########
if(PKG_CONFIG_FOUND)
    pkg_check_modules(${PC_SQLITE3_PRIVATE_VAR_NS} "sqlite3" QUIET)
    if(${PC_SQLITE3_PRIVATE_VAR_NS}_FOUND)
        if(${PC_SQLITE3_PRIVATE_VAR_NS}_VERSION)
            set(${SQLITE3_PUBLIC_VAR_NS}_VERSION "${${PC_SQLITE3_PRIVATE_VAR_NS}_VERSION}")
            string(REGEX MATCHALL "[0-9]+" ${SQLITE3_PRIVATE_VAR_NS}_VERSION_PARTS ${${PC_SQLITE3_PRIVATE_VAR_NS}_VERSION})
            list(GET ${SQLITE3_PRIVATE_VAR_NS}_VERSION_PARTS 0 ${SQLITE3_PUBLIC_VAR_NS}_VERSION_MAJOR)
            list(GET ${SQLITE3_PRIVATE_VAR_NS}_VERSION_PARTS 1 ${SQLITE3_PUBLIC_VAR_NS}_VERSION_MINOR)
            list(GET ${SQLITE3_PRIVATE_VAR_NS}_VERSION_PARTS 2 ${SQLITE3_PUBLIC_VAR_NS}_VERSION_PATCH)
        endif(${PC_SQLITE3_PRIVATE_VAR_NS}_VERSION)
    endif(${PC_SQLITE3_PRIVATE_VAR_NS}_FOUND)
endif(PKG_CONFIG_FOUND)

find_path(
    ${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR
    NAMES sqlite3.h
    PATHS ${${PC_SQLITE3_PRIVATE_VAR_NS}_INCLUDE_DIRS}
    PATH_SUFFIXES "include"
)

if(MSVC)
    include(SelectLibraryConfigurations)
    set(${SQLITE3_PRIVATE_VAR_NS}_POSSIBLE_DEBUG_NAMES "sqlite3d")
    set(${SQLITE3_PRIVATE_VAR_NS}_POSSIBLE_RELEASE_NAMES "sqlite3")

    find_library(
        ${SQLITE3_PUBLIC_VAR_NS}_LIBRARY_RELEASE
        NAMES ${${SQLITE3_PRIVATE_VAR_NS}_POSSIBLE_RELEASE_NAMES}
        DOC "Release library for SQLite3"
    )
    find_library(
        ${SQLITE3_PUBLIC_VAR_NS}_LIBRARY_DEBUG
        NAMES ${${SQLITE3_PRIVATE_VAR_NS}_POSSIBLE_DEBUG_NAMES}
        DOC "Debug library for SQLite3"
    )

    select_library_configurations("${SQLITE3_PUBLIC_VAR_NS}")
else(MSVC)
    find_library(
        ${SQLITE3_PUBLIC_VAR_NS}_LIBRARY
        NAMES sqlite3
        PATHS ${${PC_SQLITE3_PRIVATE_VAR_NS}_LIBRARY_DIRS}
    )
endif(MSVC)

if(${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR AND NOT ${SQLITE3_PUBLIC_VAR_NS}_VERSION)
    file(STRINGS "${${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR}/sqlite3.h" ${SQLITE3_PRIVATE_VAR_NS}_VERSION_NUMBER_DEFINITION LIMIT_COUNT 1 REGEX ".*# *define *SQLITE_VERSION_NUMBER *([0-9]+).*")
    string(REGEX REPLACE ".*# *define +SQLITE_VERSION_NUMBER +([0-9]+).*" "\\1" ${SQLITE3_PRIVATE_VAR_NS}_VERSION_NUMBER ${${SQLITE3_PRIVATE_VAR_NS}_VERSION_NUMBER_DEFINITION})

    math(EXPR ${SQLITE3_PUBLIC_VAR_NS}_VERSION_MAJOR "${${SQLITE3_PRIVATE_VAR_NS}_VERSION_NUMBER} / 1000000")
    math(EXPR ${SQLITE3_PUBLIC_VAR_NS}_VERSION_MINOR "(${${SQLITE3_PRIVATE_VAR_NS}_VERSION_NUMBER} - ${${SQLITE3_PUBLIC_VAR_NS}_VERSION_MAJOR} * 1000000) / 1000")
    math(EXPR ${SQLITE3_PUBLIC_VAR_NS}_VERSION_PATCH "${${SQLITE3_PRIVATE_VAR_NS}_VERSION_NUMBER} - ${${SQLITE3_PUBLIC_VAR_NS}_VERSION_MAJOR} * 1000000 - ${${SQLITE3_PUBLIC_VAR_NS}_VERSION_MINOR} * 1000")
    set(${SQLITE3_PUBLIC_VAR_NS}_VERSION "${${SQLITE3_PUBLIC_VAR_NS}_VERSION_MAJOR}.${${SQLITE3_PUBLIC_VAR_NS}_VERSION_MINOR}.${${SQLITE3_PUBLIC_VAR_NS}_VERSION_PATCH}")
endif(${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR AND NOT ${SQLITE3_PUBLIC_VAR_NS}_VERSION)

# Check find_package arguments
include(FindPackageHandleStandardArgs)
if(${SQLITE3_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${SQLITE3_PUBLIC_VAR_NS}_FIND_QUIETLY)
    find_package_handle_standard_args(
        ${SQLITE3_PUBLIC_VAR_NS}
        REQUIRED_VARS ${SQLITE3_PUBLIC_VAR_NS}_LIBRARY ${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR
        VERSION_VAR ${SQLITE3_PUBLIC_VAR_NS}_VERSION
    )
else(${SQLITE3_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${SQLITE3_PUBLIC_VAR_NS}_FIND_QUIETLY)
    find_package_handle_standard_args(${SQLITE3_PUBLIC_VAR_NS} "Could NOT find SQLite3" ${SQLITE3_PUBLIC_VAR_NS}_LIBRARY ${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR)
endif(${SQLITE3_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${SQLITE3_PUBLIC_VAR_NS}_FIND_QUIETLY)

if(${SQLITE3_PUBLIC_VAR_NS}_FOUND)
    # <deprecated>
    # for compatibility with previous versions, alias old SQLITE3_(MAJOR|MINOR|PATCH)_VERSION to SQLITE3_VERSION_$1
    set(${SQLITE3_PUBLIC_VAR_NS}_MAJOR_VERSION ${${SQLITE3_PUBLIC_VAR_NS}_VERSION_MAJOR})
    set(${SQLITE3_PUBLIC_VAR_NS}_MINOR_VERSION ${${SQLITE3_PUBLIC_VAR_NS}_VERSION_MINOR})
    set(${SQLITE3_PUBLIC_VAR_NS}_PATCH_VERSION ${${SQLITE3_PUBLIC_VAR_NS}_VERSION_PATCH})
    # </deprecated>
    set(${SQLITE3_PUBLIC_VAR_NS}_LIBRARIES ${${SQLITE3_PUBLIC_VAR_NS}_LIBRARY})
    set(${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIRS ${${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR})
    if(CMAKE_VERSION VERSION_GREATER "3.0.0")
        if(NOT TARGET SQLite3::SQLite3)
            add_library(SQLite3::SQLite3 UNKNOWN IMPORTED)
        endif(NOT TARGET SQLite3::SQLite3)
        if(${SQLITE3_PUBLIC_VAR_NS}_LIBRARY_RELEASE)
            set_property(TARGET SQLite3::SQLite3 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(SQLite3::SQLite3 PROPERTIES IMPORTED_LOCATION_RELEASE "${${SQLITE3_PUBLIC_VAR_NS}_LIBRARY_RELEASE}")
        endif(${SQLITE3_PUBLIC_VAR_NS}_LIBRARY_RELEASE)
        if(${SQLITE3_PUBLIC_VAR_NS}_LIBRARY_DEBUG)
            set_property(TARGET SQLite3::SQLite3 APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(SQLite3::SQLite3 PROPERTIES IMPORTED_LOCATION_DEBUG "${${SQLITE3_PUBLIC_VAR_NS}_LIBRARY_DEBUG}")
        endif(${SQLITE3_PUBLIC_VAR_NS}_LIBRARY_DEBUG)
        if(${SQLITE3_PUBLIC_VAR_NS}_LIBRARY)
            set_target_properties(SQLite3::SQLite3 PROPERTIES IMPORTED_LOCATION "${${SQLITE3_PUBLIC_VAR_NS}_LIBRARY}")
        endif(${SQLITE3_PUBLIC_VAR_NS}_LIBRARY)
        set_target_properties(SQLite3::SQLite3 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR}")
    endif(CMAKE_VERSION VERSION_GREATER "3.0.0")
endif(${SQLITE3_PUBLIC_VAR_NS}_FOUND)

mark_as_advanced(
    ${SQLITE3_PUBLIC_VAR_NS}_INCLUDE_DIR
    ${SQLITE3_PUBLIC_VAR_NS}_LIBRARY
)

########## <debug> ##########

if(${SQLITE3_PUBLIC_VAR_NS}_DEBUG)

    function(sqlite3_debug _VARNAME)
        if(DEFINED ${SQLITE3_PUBLIC_VAR_NS}_${_VARNAME})
            message("${SQLITE3_PUBLIC_VAR_NS}_${_VARNAME} = ${${SQLITE3_PUBLIC_VAR_NS}_${_VARNAME}}")
        else(DEFINED ${SQLITE3_PUBLIC_VAR_NS}_${_VARNAME})
            message("${SQLITE3_PUBLIC_VAR_NS}_${_VARNAME} = <UNDEFINED>")
        endif(DEFINED ${SQLITE3_PUBLIC_VAR_NS}_${_VARNAME})
    endfunction(sqlite3_debug)

    # IN (args)
    sqlite3_debug("FIND_REQUIRED")
    sqlite3_debug("FIND_QUIETLY")
    sqlite3_debug("FIND_VERSION")
    # OUT
    # Linking
    sqlite3_debug("INCLUDE_DIRS")
    sqlite3_debug("LIBRARIES")
    # Version
    sqlite3_debug("VERSION_MAJOR")
    sqlite3_debug("VERSION_MINOR")
    sqlite3_debug("VERSION_PATCH")
    sqlite3_debug("VERSION")

endif(${SQLITE3_PUBLIC_VAR_NS}_DEBUG)

########## </debug> ##########
