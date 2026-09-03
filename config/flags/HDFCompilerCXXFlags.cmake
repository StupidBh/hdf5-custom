#
# Copyright by The HDF Group.
# All rights reserved.
#
# This file is part of HDF5.  The full HDF5 copyright notice, including
# terms governing use, modification, and redistribution, is contained in
# the LICENSE file, which can be found at the root of the source code
# distribution tree, or in https://www.hdfgroup.org/licenses.
# If you do not have access to either file, you may request a copy from
# help@hdfgroup.org.
#
# Instrumentation used to define CMAKE_CXX_FLAGS before enabling C++,
# suppressing CMake's platform defaults. Preserve that initialization behavior
# while the instrumentation options themselves remain target-scoped.
if (DEFINED HDF5_CXX_FLAGS_BEFORE_INSTRUMENTATION)
  set (CMAKE_CXX_FLAGS "${HDF5_CXX_FLAGS_BEFORE_INSTRUMENTATION}")
endif ()
ENABLE_LANGUAGE (CXX)
hdf5_validate_platform_support (LANGUAGES CXX)

set (CMAKE_CXX_STANDARD 11)
set (CMAKE_CXX_STANDARD_REQUIRED TRUE)

set (CMAKE_CXX_EXTENSIONS OFF)

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_SANITIZER_FLAGS} ${CMAKE_CXX_FLAGS}")
if (DEFINED HDF5_REPORTED_CXX_FLAGS_BASE)
  set (HDF5_REPORTED_CXX_FLAGS "${CMAKE_CXX_SANITIZER_FLAGS} ${HDF5_REPORTED_CXX_FLAGS_BASE}")
else ()
  set (HDF5_REPORTED_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif ()
message (VERBOSE "Warnings Configuration: CXX default: ${CMAKE_CXX_FLAGS}")
#-----------------------------------------------------------------------------
# Compiler specific flags
#-----------------------------------------------------------------------------
# MSVC 14.28 enables C5105, but the Windows SDK 10.0.18362.0 triggers it.
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND CMAKE_CXX_COMPILER_LOADED)
  string (APPEND HDF5_REPORTED_CXX_FLAGS " /EHsc")
  if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.28)
    string (APPEND HDF5_REPORTED_CXX_FLAGS " -wd5105")
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Option to allow the user to disable compiler warnings
#-----------------------------------------------------------------------------
if (CMAKE_CXX_COMPILER_LOADED)
  if (HDF5_DISABLE_COMPILER_WARNINGS)
    message (STATUS "....Compiler warnings are suppressed")
    # MSVC uses /w to suppress warnings.  It also complains if another
    # warning level is given, so remove it.
    if (MSVC)
      string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
      string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " HDF5_REPORTED_CXX_FLAGS
          "${HDF5_REPORTED_CXX_FLAGS}"
      )
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W0")
      string (APPEND HDF5_REPORTED_CXX_FLAGS " /W0")
    else ()
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
    endif ()
  endif ()

  if (MSVC)
    include (${HDF_CONFIG_DIR}/flags/HDFMsvcCXXFlags.cmake)
  else ()
    include (${HDF_CONFIG_DIR}/flags/HDFGnuCXXFlags.cmake)
  endif ()

  #-----------------------------------------------------------------------------
  # HDF5 library compile options - to be made available to all targets
  #-----------------------------------------------------------------------------

  # General flags
  #
  # Note that some of the flags listed here really should be developer
  # flags (listed in a separate variable, below) but we put them here
  # because they are not raised by the current code and we'd like to
  # know if they do start showing up.
  #
  # NOTE: Don't add -Wpadded here since we can't/won't fix the (many)
  # warnings that are emitted. If you need it, add it at configure time.
  message (VERBOSE "CMAKE_CXX_FLAGS_GENERAL=${HDF5_CMAKE_CXX_WARNING_FLAGS}")

  #-----------------------------------------------------------------------------
  # Option to allow the user to enable all warnings
  #-----------------------------------------------------------------------------
  if (HDF5_ENABLE_ALL_WARNINGS)
    message (STATUS "....All Warnings are enabled")
    if (MSVC)
      if (HDF5_ENABLE_DEV_WARNINGS)
        string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
        string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " HDF5_REPORTED_CXX_FLAGS
            "${HDF5_REPORTED_CXX_FLAGS}"
        )
        list (APPEND HDF5_CMAKE_CXX_WARNING_FLAGS "/Wall" "/wd4668")
      else ()
        string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
        string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " HDF5_REPORTED_CXX_FLAGS
            "${HDF5_REPORTED_CXX_FLAGS}"
        )
        list (APPEND HDF5_CMAKE_CXX_WARNING_FLAGS "/W3" "/wd4100" "/wd4706" "/wd4127")
      endif ()
    else ()
      list (APPEND HDF5_CMAKE_CXX_WARNING_FLAGS ${HDF5_CMAKE_CXX_OPTIONAL_WARNING_FLAGS})
    endif ()
  endif ()

  #-----------------------------------------------------------------------------
  # This option will force/override the default setting for all configurations
  #-----------------------------------------------------------------------------
  if (HDF5_ENABLE_PROFILING)
    list (APPEND HDF5_CMAKE_CXX_BUILD_OPTION_FLAGS "${PROFILE_CXXFLAGS}")
  endif ()

  #-----------------------------------------------------------------------------
  # This option will force/override the default setting for all configurations
  #-----------------------------------------------------------------------------
  if (HDF5_ENABLE_OPTIMIZATION)
    list (APPEND HDF5_CMAKE_CXX_BUILD_OPTION_FLAGS "${OPTIMIZE_CXXFLAGS}")
  endif ()

  # Preserve the established build report fields while target ownership remains
  # split between hdf5_warnings and hdf5_build_options.
  set (HDF5_CMAKE_CXX_FLAGS
      ${HDF5_CMAKE_CXX_WARNING_FLAGS}
      ${HDF5_CMAKE_CXX_BUILD_OPTION_FLAGS}
  )

  if (NOT MSVC AND NOT DEFINED HDF5_REPORTED_CXX_FLAGS_BASE)
    set (HDF5_REPORTED_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  endif ()
  string (PREPEND HDF5_REPORTED_CXX_FLAGS "${HDF5_REPORTED_CXX_FLAGS_PREFIX}")
  string (APPEND HDF5_REPORTED_CXX_FLAGS "${HDF5_REPORTED_CXX_FLAGS_SUFFIX}")

  set (_HDF5_H5CC_CXX_COMPILER ${CMAKE_CXX_COMPILER})
  set (HDF5_H5CC_CXX_COMPILER ${_HDF5_H5CC_CXX_COMPILER} CACHE STRING "C++ compiler to use in h5c++")
  mark_as_advanced (HDF5_H5CC_CXX_COMPILER)
endif ()

#-----------------------------------------------------------------------------
# The build mode flags are not added to CMAKE_CXX_FLAGS, so create a separate
# variable for them so they can be written out to libhdf5.settings and
# H5build_settings.c
#-----------------------------------------------------------------------------
if ("${HDF_CFG_NAME}" STREQUAL     "Debug")
  set (HDF5_BUILD_MODE_CXX_FLAGS   "${CMAKE_CXX_FLAGS_DEBUG}")
elseif ("${HDF_CFG_NAME}" STREQUAL "Developer")
  set (HDF5_BUILD_MODE_CXX_FLAGS   "${CMAKE_CXX_FLAGS_DEVELOPER}")
elseif ("${HDF_CFG_NAME}" STREQUAL "Release")
  set (HDF5_BUILD_MODE_CXX_FLAGS   "${CMAKE_CXX_FLAGS_RELEASE}")
elseif ("${HDF_CFG_NAME}" STREQUAL "MinSizeRel")
  set (HDF5_BUILD_MODE_CXX_FLAGS   "${CMAKE_CXX_FLAGS_MINSIZEREL}")
elseif ("${HDF_CFG_NAME}" STREQUAL "RelWithDebInfo")
  set (HDF5_BUILD_MODE_CXX_FLAGS   "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
else ()
  set (HDF5_BUILD_MODE_CXX_FLAGS   "")
endif ()
