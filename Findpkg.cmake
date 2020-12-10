#
# This module is designed to find/handle (lib)pkg library
#
# Requirements:
# - CMake >= 2.8.3 (for new version of find_package_handle_standard_args)
#
# The following variables will be defined for your use:
#   - pkg_INCLUDE_DIRS  : pkg include directory
#   - pkg_LIBRARIES     : pkg libraries (libpkg)
#   - pkg_VERSION       : complete version of pkg (x.y.z)
#   - pkg_VERSION_MAJOR : major version of pkg
#   - pkg_VERSION_MINOR : minor version of pkg
#   - pkg_VERSION_PATCH : patch version of pkg
#   - pkg_PLUGINS_DIR   : directory from which pkg loads plugins
#   - pkg_EXECUTABLE    : path to pkg executable
#
# How to use:
#   1) Copy this file in the root of your project source directory
#   2) Then, tell CMake to search this non-standard module in your project directory by adding to your CMakeLists.txt:
#        set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#   3) Finally call find_package(pkg) once
#
# Here is a complete sample to build an executable:
#
#   set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})
#
#   find_package(pkg REQUIRED) # Note: name is case sensitive
#
#   add_executable(myapp myapp.c)
#   include_directories(${pkg_INCLUDE_DIRS})
#   target_link_libraries(myapp ${pkg_LIBRARIES})
#   # with CMake >= 3.0.0, the last two lines can be replaced by the following
#   target_link_libraries(myapp pkg::pkg) # Note: case also matters here
#


#=============================================================================
# Copyright (c) 2020, julp
#
# Distributed under the OSI-approved BSD License
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#=============================================================================

cmake_minimum_required(VERSION 2.8.3)

find_package(PkgConfig QUIET)

########## Private ##########
if(NOT DEFINED PKG_PUBLIC_VAR_NS)
    set(PKG_PUBLIC_VAR_NS "pkg")
endif(NOT DEFINED PKG_PUBLIC_VAR_NS)
if(NOT DEFINED PKG_PRIVATE_VAR_NS)
    set(PKG_PRIVATE_VAR_NS "_${PKG_PUBLIC_VAR_NS}")
endif(NOT DEFINED PKG_PRIVATE_VAR_NS)
if(NOT DEFINED PC_PKG_PRIVATE_VAR_NS)
    set(PC_PKG_PRIVATE_VAR_NS "_PC${PKG_PRIVATE_VAR_NS}")
endif(NOT DEFINED PC_PKG_PRIVATE_VAR_NS)

########## Public ##########
if(PKG_CONFIG_FOUND)
    pkg_check_modules(${PC_PKG_PRIVATE_VAR_NS} "pkg" QUIET)
    if(${PC_PKG_PRIVATE_VAR_NS}_FOUND)
        if(${PC_PKG_PRIVATE_VAR_NS}_VERSION)
            set(${PKG_PUBLIC_VAR_NS}_VERSION "${${PC_PKG_PRIVATE_VAR_NS}_VERSION}")
            string(REGEX MATCHALL "[0-9]+" ${PKG_PRIVATE_VAR_NS}_VERSION_PARTS ${${PC_PKG_PRIVATE_VAR_NS}_VERSION})
            list(GET ${PKG_PRIVATE_VAR_NS}_VERSION_PARTS 0 ${PKG_PUBLIC_VAR_NS}_VERSION_MAJOR)
            list(GET ${PKG_PRIVATE_VAR_NS}_VERSION_PARTS 1 ${PKG_PUBLIC_VAR_NS}_VERSION_MINOR)
            list(GET ${PKG_PRIVATE_VAR_NS}_VERSION_PARTS 2 ${PKG_PUBLIC_VAR_NS}_VERSION_PATCH)
        endif(${PC_PKG_PRIVATE_VAR_NS}_VERSION)
    endif(${PC_PKG_PRIVATE_VAR_NS}_FOUND)
endif(PKG_CONFIG_FOUND)

find_path(
    ${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR
    NAMES pkg.h
    PATHS ${${PC_PKG_PRIVATE_VAR_NS}_INCLUDE_DIRS}
    PATH_SUFFIXES pkg
)

find_library(
    ${PKG_PUBLIC_VAR_NS}_LIBRARY
    NAMES pkg
    PATHS ${${PC_PKG_PRIVATE_VAR_NS}_LIBRARY_DIRS}
)

find_program(${PKG_PUBLIC_VAR_NS}_EXECUTABLE pkg)
if(${PKG_PUBLIC_VAR_NS}_EXECUTABLE)
    execute_process(OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND ${${PKG_PUBLIC_VAR_NS}_EXECUTABLE} config pkg_plugins_dir OUTPUT_VARIABLE ${PKG_PUBLIC_VAR_NS}_PLUGINS_DIR)
endif(${PKG_PUBLIC_VAR_NS}_EXECUTABLE)

message("${PKG_PUBLIC_VAR_NS}_LIBRARY = ${${PKG_PUBLIC_VAR_NS}_LIBRARY}")
message("${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR = ${${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR}")

if(${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR AND NOT ${PKG_PUBLIC_VAR_NS}_VERSION)
    file(STRINGS "${${PKG_PUBLIC_VAR_NS}_INCLUDE_DIRS}/pkg.h" ${PKG_PRIVATE_VAR_NS}_VERSION_STRING LIMIT_COUNT 1 REGEX "# *define +PKGVERSION *\"[0-9]+\\.[0-9]+\\.[0-9]+\"")
    string(REGEX REPLACE "# *define +PKGVERSION *\"([0-9.]+)\"" "\\1" ${PKG_PUBLIC_VAR_NS}_VERSION ${${PKG_PRIVATE_VAR_NS}_VERSION_STRING})
    string(REGEX MATCHALL "[0-9]+" ${PKG_PRIVATE_VAR_NS}_VERSION_PARTS ${${PKG_PUBLIC_VAR_NS}_VERSION})
    list(GET ${PKG_PRIVATE_VAR_NS}_VERSION_PARTS 0 ${PKG_PUBLIC_VAR_NS}_VERSION_MAJOR)
    list(GET ${PKG_PRIVATE_VAR_NS}_VERSION_PARTS 1 ${PKG_PUBLIC_VAR_NS}_VERSION_MINOR)
    list(GET ${PKG_PRIVATE_VAR_NS}_VERSION_PARTS 2 ${PKG_PUBLIC_VAR_NS}_VERSION_PATCH)
endif(${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR AND NOT ${PKG_PUBLIC_VAR_NS}_VERSION)

# Check find_package arguments
include(FindPackageHandleStandardArgs)
if(${PKG_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${PKG_PUBLIC_VAR_NS}_FIND_QUIETLY)
    find_package_handle_standard_args(
        ${PKG_PUBLIC_VAR_NS}
        REQUIRED_VARS ${PKG_PUBLIC_VAR_NS}_LIBRARY ${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR
        VERSION_VAR ${PKG_PUBLIC_VAR_NS}_VERSION
    )
else(${PKG_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${PKG_PUBLIC_VAR_NS}_FIND_QUIETLY)
    find_package_handle_standard_args(${PKG_PUBLIC_VAR_NS} "Could NOT find libpkg" ${PKG_PUBLIC_VAR_NS}_LIBRARY ${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR)
endif(${PKG_PUBLIC_VAR_NS}_FIND_REQUIRED AND NOT ${PKG_PUBLIC_VAR_NS}_FIND_QUIETLY)

if(${PKG_PUBLIC_VAR_NS}_FOUND)
    set(${PKG_PUBLIC_VAR_NS}_LIBRARIES ${${PKG_PUBLIC_VAR_NS}_LIBRARY})
    set(${PKG_PUBLIC_VAR_NS}_INCLUDE_DIRS ${${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR})
    if(CMAKE_VERSION VERSION_GREATER "3.0.0")
        if(NOT TARGET pkg::pkg)
            add_library(pkg::pkg UNKNOWN IMPORTED)
        endif(NOT TARGET pkg::pkg)
        if(${PKG_PUBLIC_VAR_NS}_LIBRARY_RELEASE)
            set_property(TARGET pkg::pkg APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(pkg::pkg PROPERTIES IMPORTED_LOCATION_RELEASE "${${PKG_PUBLIC_VAR_NS}_LIBRARY_RELEASE}")
        endif(${PKG_PUBLIC_VAR_NS}_LIBRARY_RELEASE)
        if(${PKG_PUBLIC_VAR_NS}_LIBRARY_DEBUG)
            set_property(TARGET pkg::pkg APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(pkg::pkg PROPERTIES IMPORTED_LOCATION_DEBUG "${${PKG_PUBLIC_VAR_NS}_LIBRARY_DEBUG}")
        endif(${PKG_PUBLIC_VAR_NS}_LIBRARY_DEBUG)
        if(${PKG_PUBLIC_VAR_NS}_LIBRARY)
            set_target_properties(pkg::pkg PROPERTIES IMPORTED_LOCATION "${${PKG_PUBLIC_VAR_NS}_LIBRARY}")
        endif(${PKG_PUBLIC_VAR_NS}_LIBRARY)
        set_target_properties(pkg::pkg PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR}")
    endif(CMAKE_VERSION VERSION_GREATER "3.0.0")
endif(${PKG_PUBLIC_VAR_NS}_FOUND)

mark_as_advanced(
    ${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR
    ${PKG_PUBLIC_VAR_NS}_LIBRARY
)

macro(pkg_plugin)
    cmake_parse_arguments(
        PKG_PLUGIN # output variable name
        # options (true/false) (default value: false)
        "INSTALL"
        # univalued parameters (default value: "")
        "NAME"
        # multivalued parameters (default value: "")
        "INCLUDE_DIRECTORIES;LIBRARIES;SOURCES"
        ${ARGN}
    )

    if(NOT PKG_PLUGIN_NAME)
        message(FATAL_ERROR "pkg_plugin, missing expected argument: NAME")
    endif(NOT PKG_PLUGIN_NAME)
    if(NOT PKG_PLUGIN_SOURCES)
        message(FATAL_ERROR "pkg_plugin, missing expected argument: SOURCES")
    endif(NOT PKG_PLUGIN_SOURCES)

    add_library(${PKG_PLUGIN_NAME} SHARED ${PKG_PLUGIN_SOURCES})
    if(PKG_PLUGIN_LIBRARIES)
        target_link_libraries(${PKG_PLUGIN_NAME} ${PKG_PLUGIN_LIBRARIES} ${${PKG_PUBLIC_VAR_NS}_LIBRARY})
    endif(PKG_PLUGIN_LIBRARIES)

    set(PKG_PLUGIN_INCLUDE_DIRS )
    list(APPEND PKG_PLUGIN_INCLUDE_DIRS ${PROJECT_SOURCE_DIR})
    list(APPEND PKG_PLUGIN_INCLUDE_DIRS ${PROJECT_BINARY_DIR})
    list(APPEND PKG_PLUGIN_INCLUDE_DIRS ${${PKG_PUBLIC_VAR_NS}_INCLUDE_DIR})
    list(APPEND PKG_PLUGIN_INCLUDE_DIRS ${PKG_PLUGIN_INCLUDE_DIRECTORIES})

    set_target_properties(${PKG_PLUGIN_NAME} PROPERTIES
        PREFIX ""
        INCLUDE_DIRECTORIES "${PKG_PLUGIN_INCLUDE_DIRS}"
    )

    if(PKG_PLUGIN_INSTALL)
        install(TARGETS ${PKG_PLUGIN_NAME} DESTINATION ${${PKG_PUBLIC_VAR_NS}_PLUGINS_DIR})
    endif(PKG_PLUGIN_INSTALL)
endmacro(pkg_plugin)

########## <debug> ##########

if(${PKG_PUBLIC_VAR_NS}_DEBUG)

    function(pkg_debug _VARNAME)
        if(DEFINED ${PKG_PUBLIC_VAR_NS}_${_VARNAME})
            message("${PKG_PUBLIC_VAR_NS}_${_VARNAME} = ${${PKG_PUBLIC_VAR_NS}_${_VARNAME}}")
        else(DEFINED ${PKG_PUBLIC_VAR_NS}_${_VARNAME})
            message("${PKG_PUBLIC_VAR_NS}_${_VARNAME} = <UNDEFINED>")
        endif(DEFINED ${PKG_PUBLIC_VAR_NS}_${_VARNAME})
    endfunction(pkg_debug)

    # IN (args)
    pkg_debug("FIND_REQUIRED")
    pkg_debug("FIND_QUIETLY")
    pkg_debug("FIND_VERSION")
    # OUT
    # executable
    pkg_debug("EXECUTABLE")
    # Linking
    pkg_debug("INCLUDE_DIRS")
    pkg_debug("LIBRARIES")
    # Plugin
    pkg_debug("PLUGINS_DIR")
    # Version
    pkg_debug("VERSION_MAJOR")
    pkg_debug("VERSION_MINOR")
    pkg_debug("VERSION_PATCH")
    pkg_debug("VERSION")

endif(${PKG_PUBLIC_VAR_NS}_DEBUG)

########## </debug> ##########
