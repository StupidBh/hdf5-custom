#
# Copyright (C) 2018-2020 by George Cave - gcave@stablecoder.ca
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# USAGE: To enable any code coverage instrumentation/targets, the single CMake
# option of `CODE_COVERAGE` needs to be set to 'ON', either by GUI, ccmake, or
# on the command line.
#
# From this point, there are two primary methods for adding instrumentation to
# targets: 1 - A blanket instrumentation by calling `add_code_coverage()`, where
# all targets in that directory and all subdirectories are automatically
# instrumented. 2 - Per-target instrumentation by calling
# `target_code_coverage(<TARGET_NAME>)`, where the target is given and thus only
# that target is instrumented. This applies to both libraries and executables.
#
# To add coverage targets, such as calling `make ccov` to generate the actual
# coverage information for perusal or consumption, call
# `target_code_coverage(<TARGET_NAME>)` on an *executable* target.
#
# Example 1: All targets instrumented
#
# In this case, the coverage information reported will will be that of the
# `theLib` library target and `theExe` executable.
#
# 1a: Via global command
#
# ~~~
# add_code_coverage() # Adds instrumentation to all targets
#
# add_library(theLib lib.cpp)
#
# add_executable(theExe main.cpp)
# target_link_libraries(theExe PRIVATE theLib)
# target_code_coverage(theExe) # As an executable target, adds the 'ccov-theExe' target (instrumentation already added via global anyways) for generating code coverage reports.
# ~~~
#
# 1b: Via target commands
#
# ~~~
# add_library(theLib lib.cpp)
# target_code_coverage(theLib) # As a library target, adds coverage instrumentation but no targets.
#
# add_executable(theExe main.cpp)
# target_link_libraries(theExe PRIVATE theLib)
# target_code_coverage(theExe) # As an executable target, adds the 'ccov-theExe' target and instrumentation for generating code coverage reports.
# ~~~
#
# Example 2: Target instrumented, but with regex pattern of files to be excluded
# from report
#
# ~~~
# add_executable(theExe main.cpp non_covered.cpp)
# target_code_coverage(theExe EXCLUDE non_covered.cpp test/*) # As an executable target, the reports will exclude the non-covered.cpp file, and any files in a test/ folder.
# ~~~
#
# Example 3: Target added to the 'ccov' and 'ccov-all' targets
#
# ~~~
# add_code_coverage_all_targets(EXCLUDE test/*) # Adds the 'ccov-all' target set and sets it to exclude all files in test/ folders.
#
# add_executable(theExe main.cpp non_covered.cpp)
# target_code_coverage(theExe AUTO ALL EXCLUDE non_covered.cpp test/*) # As an executable target, adds to the 'ccov' and ccov-all' targets, and the reports will exclude the non-covered.cpp file, and any files in a test/ folder.
# ~~~

# Options
option(
  CODE_COVERAGE
  "Builds targets with code coverage instrumentation. (Requires GCC)"
  OFF)

# Programs
find_program(LCOV_PATH lcov)
message(VERBOSE "program lcov=${LCOV_PATH}")
find_program(GENHTML_PATH genhtml)
message(VERBOSE "program genhtml=${GENHTML_PATH}")
# Hide behind the 'advanced' mode flag for GUI/ccmake
mark_as_advanced(FORCE LCOV_PATH GENHTML_PATH)

# Variables
set(CMAKE_COVERAGE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/ccov)

# Common initialization/checks
if(CODE_COVERAGE AND NOT CODE_COVERAGE_ADDED)
  set(CODE_COVERAGE_ADDED ON)

  # Common Targets
  file(MAKE_DIRECTORY ${CMAKE_COVERAGE_OUTPUT_DIRECTORY})

  if(CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # Messages
    message(STATUS "Building with lcov Code Coverage Tools")

    if(CMAKE_BUILD_TYPE)
      string(TOUPPER ${CMAKE_BUILD_TYPE} upper_build_type)
      if(NOT ${upper_build_type} STREQUAL "DEBUG")
        message(
          WARNING
            "Code coverage results with an optimized (non-Debug) build may be misleading"
        )
      endif()
    else()
      message(
        WARNING
          "Code coverage results with an optimized (non-Debug) build may be misleading"
      )
    endif()
    if(NOT LCOV_PATH)
      message(FATAL_ERROR "lcov not found! Aborting...")
    endif()
    if(NOT GENHTML_PATH)
      message(FATAL_ERROR "genhtml not found! Aborting...")
    endif()

    # Targets
    add_custom_target (ccov-clean COMMAND ${LCOV_PATH} --directory
                                         ${CMAKE_BINARY_DIR} --zerocounters)

  else()
    set(CODE_COVERAGE_ADDED OFF)
    message(STATUS "Code coverage requires GCC.(${CMAKE_C_COMPILER_ID})")
  endif()
endif()

# Adds code coverage instrumentation to a library, or instrumentation/targets
# for an executable target.
# ~~~
# EXECUTABLE ADDED TARGETS:
# GCOV/LCOV:
# ccov : Generates HTML code coverage report for every target added with 'AUTO' parameter.
# ccov-${TARGET_NAME} : Generates HTML code coverage report for the associated named target.
# ccov-all : Generates HTML code coverage report, merging every target added with 'ALL' parameter into a single detailed report.
#
# Required:
# TARGET_NAME - Name of the target to generate code coverage for.
# Optional:
# PUBLIC - Sets the visibility for added compile options to targets to PUBLIC instead of the default of PRIVATE.
# INTERFACE - Sets the visibility for added compile options to targets to INTERFACE instead of the default of PRIVATE.
# PLAIN - Do not set any target visibility (backward compatibility with old cmake projects)
# AUTO - Adds the target to the 'ccov' target so that it can be run in a batch with others easily. Effective on executable targets.
# ALL - Adds the target to the 'ccov-all' and 'ccov-all-report' targets, which merge several executable targets coverage data to a single report. Effective on executable targets.
# EXTERNAL - For GCC's lcov, allows the profiling of 'external' files from the processing directory
# COVERAGE_TARGET_NAME - For executables ONLY, changes the outgoing target name so instead of `ccov-${TARGET_NAME}` it becomes `ccov-${COVERAGE_TARGET_NAME}`.
# EXCLUDE <PATTERNS> - Excludes files matching the provided glob patterns. **These do not copy to the 'all' targets.**
# PRE_ARGS <ARGUMENTS> - For executables ONLY, prefixes given arguments to the associated ccov-* executable call ($<PRE_ARGS> ccov-*)
# ARGS <ARGUMENTS> - For executables ONLY, appends the given arguments to the associated ccov-* executable call (ccov-* $<ARGS>)
# ~~~
function(target_code_coverage TARGET_NAME)
  # Argument parsing
  set(options AUTO ALL EXTERNAL PUBLIC INTERFACE PLAIN)
  set(single_value_keywords COVERAGE_TARGET_NAME)
  set(multi_value_keywords EXCLUDE PRE_ARGS ARGS)
  cmake_parse_arguments(
    target_code_coverage "${options}" "${single_value_keywords}"
    "${multi_value_keywords}" ${ARGN})

  # Set the visibility of target functions to PUBLIC, INTERFACE or default to
  # PRIVATE.
  if(target_code_coverage_PUBLIC)
    set(TARGET_VISIBILITY PUBLIC)
    set(TARGET_LINK_VISIBILITY PUBLIC)
  elseif(target_code_coverage_INTERFACE)
    set(TARGET_VISIBILITY INTERFACE)
    set(TARGET_LINK_VISIBILITY INTERFACE)
  elseif(target_code_coverage_PLAIN)
    set(TARGET_VISIBILITY PUBLIC)
    set(TARGET_LINK_VISIBILITY)
  else()
    set(TARGET_VISIBILITY PRIVATE)
    set(TARGET_LINK_VISIBILITY PRIVATE)
  endif()

  if(NOT target_code_coverage_COVERAGE_TARGET_NAME)
    # If a specific name was given, use that instead.
    set(target_code_coverage_COVERAGE_TARGET_NAME ${TARGET_NAME})
  endif()

  if(CODE_COVERAGE)

    # Add code coverage instrumentation to the target's linker command
    if(CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      target_compile_options(
        ${TARGET_NAME} ${TARGET_VISIBILITY} -fprofile-arcs -ftest-coverage
        $<$<COMPILE_LANGUAGE:CXX>:-fno-elide-constructors> -fno-default-inline)
      target_link_libraries(${TARGET_NAME} ${TARGET_LINK_VISIBILITY} gcov)
    endif()

    # Targets
    get_target_property(target_type ${TARGET_NAME} TYPE)

    # For executables add targets to run and produce output
    if(target_type STREQUAL "EXECUTABLE")
      if(CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(COVERAGE_INFO
            "${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${target_code_coverage_COVERAGE_TARGET_NAME}.info"
        )

        # Run the executable, generating coverage information
        add_custom_target (
          ccov-run-${target_code_coverage_COVERAGE_TARGET_NAME}
          COMMAND
            ${target_code_coverage_PRE_ARGS}
            $<TARGET_FILE:${TARGET_NAME}> ${target_code_coverage_ARGS}
          DEPENDS ${TARGET_NAME})

        # Generate exclusion string for use
        foreach(EXCLUDE_ITEM ${target_code_coverage_EXCLUDE})
          set(EXCLUDE_REGEX ${EXCLUDE_REGEX} --remove ${COVERAGE_INFO}
                            '${EXCLUDE_ITEM}')
        endforeach()

        if(EXCLUDE_REGEX)
          set(EXCLUDE_COMMAND COMMAND ${LCOV_PATH} ${EXCLUDE_REGEX}
                                      --output-file ${COVERAGE_INFO})
        else()
          set(EXCLUDE_COMMAND)
        endif()

        if(NOT ${target_code_coverage_EXTERNAL})
          set(EXTERNAL_OPTION --no-external)
        endif()

        # Capture coverage data
        add_custom_target (
          ccov-capture-${target_code_coverage_COVERAGE_TARGET_NAME}
          COMMAND ${CMAKE_COMMAND} -E rm -f ${COVERAGE_INFO}
          COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --zerocounters
          COMMAND
            ${target_code_coverage_PRE_ARGS}
            $<TARGET_FILE:${TARGET_NAME}> ${target_code_coverage_ARGS}
          COMMAND
            ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --base-directory
            ${CMAKE_SOURCE_DIR} --capture ${EXTERNAL_OPTION} --output-file
            ${COVERAGE_INFO}
          ${EXCLUDE_COMMAND}
          DEPENDS ${TARGET_NAME})

        # Generates HTML output of the coverage information for perusal
        add_custom_target (
          ccov-${target_code_coverage_COVERAGE_TARGET_NAME}
          COMMAND
            ${GENHTML_PATH} -o
            ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${target_code_coverage_COVERAGE_TARGET_NAME}
            ${COVERAGE_INFO}
          DEPENDS ccov-capture-${target_code_coverage_COVERAGE_TARGET_NAME})
      endif()

      add_custom_command(
        TARGET ccov-${target_code_coverage_COVERAGE_TARGET_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo
          "Open ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/${target_code_coverage_COVERAGE_TARGET_NAME}/index.html in your browser to view the coverage report."
      )

      # AUTO
      if(target_code_coverage_AUTO)
        if(NOT TARGET ccov)
          add_custom_target (ccov)
        endif()
        add_dependencies(ccov ccov-${target_code_coverage_COVERAGE_TARGET_NAME})
      endif()

      # ALL
      if(target_code_coverage_ALL)
        if(NOT TARGET ccov-all-processing)
          message(
            FATAL_ERROR
              "Calling target_code_coverage with 'ALL' must be after a call to 'add_code_coverage_all_targets'."
          )
        endif()

        add_dependencies(ccov-all-processing
                         ccov-run-${target_code_coverage_COVERAGE_TARGET_NAME})
      endif()
    endif()
  endif()
endfunction()

# Returns code coverage usage requirements for a caller-owned target.
function(code_coverage_get_options COMPILE_OPTIONS_VAR LINK_OPTIONS_VAR LINK_LIBRARIES_VAR)
  set(coverage_compile_options)
  set(coverage_link_options)
  set(coverage_link_libraries)

  if(CODE_COVERAGE)
    if(CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      list(APPEND coverage_compile_options
        -fprofile-arcs -ftest-coverage
        $<$<COMPILE_LANGUAGE:CXX>:-fno-elide-constructors> -fno-default-inline)
      list(APPEND coverage_link_libraries gcov)
    endif()
  endif()

  set(${COMPILE_OPTIONS_VAR} "${coverage_compile_options}")
  set(${LINK_OPTIONS_VAR} "${coverage_link_options}")
  set(${LINK_LIBRARIES_VAR} "${coverage_link_libraries}")
  return(PROPAGATE ${COMPILE_OPTIONS_VAR} ${LINK_OPTIONS_VAR} ${LINK_LIBRARIES_VAR})
endfunction()

# Adds code coverage instrumentation to all targets in the current directory and
# any subdirectories. To add coverage instrumentation to only specific targets,
# use `target_code_coverage`.
function(add_code_coverage)
  code_coverage_get_options(coverage_compile_options coverage_link_options
                            coverage_link_libraries)
  if(coverage_compile_options)
    add_compile_options(${coverage_compile_options})
  endif()
  if(coverage_link_options)
    add_link_options(${coverage_link_options})
  endif()
  if(coverage_link_libraries)
    link_libraries(${coverage_link_libraries})
  endif()
endfunction()

# Adds the 'ccov-all' type targets that calls all targets added via
# `target_code_coverage` with the `ALL` parameter, but merges all the coverage
# data from them into a single large report  instead of the numerous smaller
# reports. Also adds the ccov-all-capture Generates an all-merged.info file, for
# use with coverage dashboards (e.g. codecov.io, coveralls).
# ~~~
# Optional:
# EXCLUDE <PATTERNS> - Excludes files matching the provided glob patterns.
# ~~~
function(add_code_coverage_all_targets)
  # Argument parsing
  set(multi_value_keywords EXCLUDE)
  cmake_parse_arguments(add_code_coverage_all_targets "" ""
                        "${multi_value_keywords}" ${ARGN})

  if(CODE_COVERAGE AND
     (CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))
    set(COVERAGE_INFO "${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/all-merged.info")

    # Nothing required for gcov
    add_custom_target (ccov-all-processing)

    # Exclusion regex string creation
    set(EXCLUDE_REGEX)
    foreach(EXCLUDE_ITEM ${add_code_coverage_all_targets_EXCLUDE})
      set(EXCLUDE_REGEX ${EXCLUDE_REGEX} --remove ${COVERAGE_INFO}
                        '${EXCLUDE_ITEM}')
    endforeach()

    if(EXCLUDE_REGEX)
      set(EXCLUDE_COMMAND COMMAND ${LCOV_PATH} ${EXCLUDE_REGEX}
                                  --output-file ${COVERAGE_INFO})
    else()
      set(EXCLUDE_COMMAND)
    endif()

    # Capture coverage data
    add_custom_target (
      ccov-all-capture
      COMMAND ${CMAKE_COMMAND} -E rm -f ${COVERAGE_INFO}
      COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --capture
              --output-file ${COVERAGE_INFO}
      ${EXCLUDE_COMMAND}
      DEPENDS ccov-all-processing)

    # Generates HTML output of all targets for perusal
    add_custom_target (
      ccov-all
      COMMAND ${GENHTML_PATH} -o ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/all-merged
              ${COVERAGE_INFO} -p ${CMAKE_SOURCE_DIR}
      DEPENDS ccov-all-capture)

    add_custom_command(
      TARGET ccov-all
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E echo
        "Open ${CMAKE_COVERAGE_OUTPUT_DIRECTORY}/all-merged/index.html in your browser to view the coverage report."
    )
  endif()
endfunction()
