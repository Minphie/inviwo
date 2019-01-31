#################################################################################
#
# Inviwo - Interactive Visualization Workshop
#
# Copyright (c) 2013-2018 Inviwo Foundation
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
#################################################################################
 
set(IVW_MAJOR_VERSION 0)
set(IVW_MINOR_VERSION 9)
set(IVW_PATCH_VERSION 9)
set(IVW_BUILD_VERSION 1) # set to zero when doing a release, bump to 1 directly after the release. 

if(${IVW_BUILD_VERSION})
    set(IVW_VERSION ${IVW_MAJOR_VERSION}.${IVW_MINOR_VERSION}.${IVW_PATCH_VERSION}.${IVW_BUILD_VERSION})
else() # if IVW_BUILD_VERSION is not set or set to zero 
    set(IVW_VERSION ${IVW_MAJOR_VERSION}.${IVW_MINOR_VERSION}.${IVW_PATCH_VERSION})
endif()

#--------------------------------------------------------------------
# Requirement checks
include(CheckCXXCompilerFlag)
if(MSVC) 
    if(MSVC_VERSION LESS 1900)
        message(FATAL_ERROR "Inviwo requires C++14 features. " 
                "You need at least Visual Studio 14 (Microsoft Visual Studio 2015) "
                "The latest Visual Studio version is available at "
                "https://www.visualstudio.com/en-us/downloads/download-visual-studio-vs.aspx")
    endif()
    CHECK_CXX_COMPILER_FLAG("/std:c++14" compiler_supports_cxx14)
    CHECK_CXX_COMPILER_FLAG("/std:c++17" compiler_supports_cxx17)
else()
    CHECK_CXX_COMPILER_FLAG("-std=c++14" compiler_supports_cxx14)
    CHECK_CXX_COMPILER_FLAG("-std=c++17" compiler_supports_cxx17)
endif()
if(compiler_supports_cxx17)
    message(STATUS "C++17 enabled")
    set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ ISO Standard" FORCE)
elseif(compiler_supports_cxx14)
    message(STATUS "C++14 enabled")
    set(CMAKE_CXX_STANDARD 14 CACHE STRING "C++ ISO Standard" FORCE) 
else()
    message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++14 support. "
            "Please use a different C++ compiler.")
endif()
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(WARNING "Inviwo is only supported for 64-bit architectures.")
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS On)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER cmake)

#--------------------------------------------------------------------
# CMake debugging
option(IVW_CMAKE_DEBUG "Print CMake Debug Information" OFF)

if(IVW_CMAKE_DEBUG)
    function(log_proj variable access value file stack)
        if(${access} STREQUAL "MODIFIED_ACCESS")
            get_filename_component(path ${file} DIRECTORY)
            get_filename_component(name ${path} NAME)
            message(STATUS "Variable: ${variable} = ${value}, ${name}")
        endif()
    endfunction()

    #variable_watch(OpenMP_ON)
    #variable_watch(_projectName log_proj)
endif()

# Make sure we print deprecation warnings
set(CMAKE_WARN_DEPRECATED ON)

function(ivw_debug_message)
    if(IVW_CMAKE_DEBUG)
        message(${ARGV})
    endif()
endfunction()

#--------------------------------------------------------------------
# Add our cmake modules to search path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/modules")

#--------------------------------------------------------------------
# Add parameter for paths to external modules
set(IVW_EXTERNAL_MODULES "" CACHE STRING "Semicolon (;) separated paths to directories containing external modules")
# Convert to valid paths, i.e. exchange backslash to slash
file(TO_CMAKE_PATH "${IVW_EXTERNAL_MODULES}" IVW_EXTERNAL_MODULES)
#--------------------------------------------------------------------
# Add parameter for paths to external projects
set(IVW_EXTERNAL_PROJECTS "" CACHE STRING "Semicolon (;) separated paths to directories with apps. CMake add_subdirectory will be called for each path.")
# Convert to valid paths, i.e. exchange backslash to slash
file(TO_CMAKE_PATH "${IVW_EXTERNAL_PROJECTS}" IVW_EXTERNAL_PROJECTS)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib CACHE PATH
   "Single Directory for all static libraries.")

#--------------------------------------------------------------------
# Output paths for the executables, runtimes, archives and libraries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin CACHE PATH
   "Single Directory for all Executables.")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib CACHE PATH
   "Single Directory for all Libraries")

#--------------------------------------------------------------------
# Path for this solution
if(NOT EXECUTABLE_OUTPUT_PATH)
    set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin CACHE PATH 
        "Single output directory for building all executables.")
endif()
if(NOT LIBRARY_OUTPUT_PATH)
    set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib CACHE PATH
        "Single output directory for building all libraries.")
endif()

# Set Common Variables
get_filename_component(IVW_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR} PATH)
set(IVW_INCLUDE_DIR             ${IVW_ROOT_DIR}/include)
set(IVW_SOURCE_DIR              ${IVW_ROOT_DIR}/src)
set(IVW_CORE_INCLUDE_DIR        ${IVW_ROOT_DIR}/include/inviwo/core)
set(IVW_CORE_SOURCE_DIR         ${IVW_ROOT_DIR}/src/core)
set(IVW_QT_INCLUDE_DIR          ${IVW_ROOT_DIR}/include/inviwo/qt)
set(IVW_QT_SOURCE_DIR           ${IVW_ROOT_DIR}/src/qt)
set(IVW_APPLICATION_DIR         ${IVW_ROOT_DIR}/apps)
set(IVW_MODULE_DIR              ${IVW_ROOT_DIR}/modules)
set(IVW_RESOURCES_DIR           ${IVW_ROOT_DIR}/resources)
set(IVW_EXTENSIONS_DIR          ${IVW_ROOT_DIR}/ext)
set(IVW_TOOLS_DIR               ${IVW_ROOT_DIR}/tools)
set(IVW_BINARY_DIR              ${CMAKE_BINARY_DIR})
set(IVW_LIBRARY_DIR             ${LIBRARY_OUTPUT_PATH})
set(IVW_EXECUTABLE_DIR          ${EXECUTABLE_OUTPUT_PATH})
set(IVW_CMAKE_SOURCE_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR}/modules)
set(IVW_CMAKE_BINARY_MODULE_DIR ${CMAKE_BINARY_DIR}/cmake)
set(IVW_CMAKE_TEMPLATES         ${IVW_ROOT_DIR}/cmake/templates)

#--------------------------------------------------------------------
# Add globalmacros
include(${CMAKE_CURRENT_LIST_DIR}/globalutils.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/compileoptions.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/installutils.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/deprecated.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/filegeneration.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/globalmacros.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/licenses.cmake)

#Generate headers
ivw_generate_module_paths_header()
configure_file(${IVW_CMAKE_TEMPLATES}/inviwocommondefines_template.h 
               ${CMAKE_BINARY_DIR}/modules/core/include/inviwo/core/inviwocommondefines.h 
               @ONLY IMMEDIATE)

#--------------------------------------------------------------------
# Mac specific
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    add_definitions(-DDARWIN)
endif()

#--------------------------------------------------------------------
# Package creation
option(IVW_PACKAGE_PROJECT "Create Inviwo Package Project" OFF)

#--------------------------------------------------------------------
# Use and generate resources when available
include(${CMAKE_CURRENT_LIST_DIR}/compileresources.cmake)

#--------------------------------------------------------------------
# Calculate and display profiling information
option(IVW_PROFILING "Enable profiling" OFF)

#--------------------------------------------------------------------
# Build unittest for all modules
include(${CMAKE_CURRENT_LIST_DIR}/unittests.cmake)

#--------------------------------------------------------------------
# Use Visual Studio memory leak test
include(${CMAKE_CURRENT_LIST_DIR}/memleak.cmake)

#--------------------------------------------------------------------
# Use pybind11 for python bindings
include(${CMAKE_CURRENT_LIST_DIR}/pybind11.cmake)

#--------------------------------------------------------------------
# Build shared libs or static libs
mark_as_advanced(FORCE GLM_DIR)
mark_as_advanced(FORCE CMAKE_CONFIGURATION_TYPES)

if(WIN32 AND MSVC)
    # Determine runtime library linkage depending on BUILD_SHARED_LIBS setting.
    # Shared runtime can be forced by setting the IVW_FORCE_SHARED_CRT option.
    option(IVW_FORCE_SHARED_CRT "Use shared runtime library linkage for Inviwo" OFF)
    mark_as_advanced(IVW_FORCE_SHARED_CRT)
    if(BUILD_SHARED_LIBS OR IVW_FORCE_SHARED_CRT)
        add_compile_options(
            $<$<CONFIG:Release>:/MD> 
            $<$<CONFIG:MinSizeRel>:/MD> 
            $<$<CONFIG:Debug>:/MDd> 
            $<$<CONFIG:RelWithDebInfo>:/MD>
        )
    else()
        add_compile_options(
            $<$<CONFIG:Release>:/MT> 
            $<$<CONFIG:MinSizeRel>:/MT> 
            $<$<CONFIG:Debug>:/MTd> 
            $<$<CONFIG:RelWithDebInfo>:/MT>
        )
    endif()

    # For >=VS2015 enable edit and continue "ZI"
    add_compile_options($<$<CONFIG:Debug>:/ZI>)

    add_compile_options(/bigobj)

    # set iterator debug level (default=2)
    # https://msdn.microsoft.com/en-us/library/hh697468.aspx
    set(IVW_ITERATOR_DEBUG_LEVEL "2" CACHE STRING "Iterator debug level (IDL, default=2). 
    IDL=0: Disables checked iterators and disables iterator debugging.
    IDL=1: Enables checked iterators and disables iterator debugging.
    IDL=2: Enables iterator debugging. Note: QT needs to be built with the same flag")
    set_property(CACHE IVW_ITERATOR_DEBUG_LEVEL PROPERTY STRINGS 0 1 2)
    add_compile_options($<$<CONFIG:Debug>:/D_ITERATOR_DEBUG_LEVEL=${IVW_ITERATOR_DEBUG_LEVEL}>)

    # Multicore builds
    option(IVW_MULTI_PROCESSOR_BUILD "Build with multiple processors" ON)
    set(IVW_MULTI_PROCESSOR_COUNT 0 CACHE STRING "Number of cores to use (defalt 0 = all)")
    if(IVW_MULTI_PROCESSOR_BUILD)
        if(IVW_MULTI_PROCESSOR_COUNT GREATER 1 AND IVW_MULTI_PROCESSOR_COUNT LESS 1024)
            add_compile_options(/MP${IVW_MULTI_PROCESSOR_COUNT})
        else()
            add_compile_options(/MP)
        endif()
    endif()

    if(NOT ${CMAKE_VERSION} VERSION_LESS "3.6")
        set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT inviwo)
    endif()
endif()

if(UNIX AND NOT APPLE)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON) # Will add -fPIC under linux.
    set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--as-needed") # Only link to libs as needed.
endif()

#--------------------------------------------------------------------
# Calculate and display profiling information
option(IVW_RUNTIME_MODULE_LOADING 
       "Load modules from dynamic libraries (dll/so) at application startup" OFF)

#--------------------------------------------------------------------
# Check if OpenMP is available and set it to use, and include the dll in packs
find_package(OpenMP QUIET)
option(OpenMP_ON "Use OpenMP" ${OPENMP_FOUND})
if(OpenMP_ON AND OPENMP_FOUND)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
elseif(OpenMP_ON)
    message(FATAL_ERROR "OpenMP not available")
endif()


#--------------------------------------------------------------------
# Set preprocessor definition to indicate whether 
# to use the debug postfix
# Add debug postfix if WIN32
IF(WIN32 AND MSVC)
    SET(CMAKE_DEBUG_POSTFIX "d")
ENDIF()

if(DEBUG_POSTFIX)
    add_definitions(-D_DEBUG_POSTFIX)
endif(DEBUG_POSTFIX)

#--------------------------------------------------------------------
# Add option to enable include-what-you-use 
# https://github.com/include-what-you-use/include-what-you-use
if (${CMAKE_GENERATOR} STREQUAL "Unix Makefiles" OR ${CMAKE_GENERATOR} STREQUAL "Ninja")
    find_program(iwyu_path NAMES include-what-you-use iwyu)
    if(iwyu_path)
        option(IVW_ENABLE_INCLUDE_WHAT_YOU_USE "Enable include-what-you-use" OFF)
        if(IVW_ENABLE_INCLUDE_WHAT_YOU_USE)
            set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${iwyu_path})
        endif()
    endif()
endif()

#--------------------------------------------------------------------
# force colors when using clang and ninja https://github.com/ninja-build/ninja/wiki/FAQ
if (${CMAKE_GENERATOR} STREQUAL "Ninja" AND "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    add_compile_options(-fcolor-diagnostics)
endif()

#--------------------------------------------------------------------
# Precompile headers
if(WIN32)
    option(PRECOMPILED_HEADERS "Create and use precompilied headers" ON)
else()
    option(PRECOMPILED_HEADERS "Create and use precompilied headers" OFF)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/utilities/clean_library_list.cmake)
if(PRECOMPILED_HEADERS)
    include(${CMAKE_CURRENT_LIST_DIR}/cotire.cmake)
endif()
