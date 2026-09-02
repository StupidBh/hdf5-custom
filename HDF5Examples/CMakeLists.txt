# Top-level CMake configuration for HDF5 Examples
# This file sets up build options, dependencies, and subdirectories for C, C++,
# Python, and filter examples.
# It also handles MPI/parallel support, version parsing, and testing configuration.
#
# The option naming convention is H5EXAMPLE_* for examples options and HDF5_* for HDF5
# library features.

cmake_minimum_required (VERSION 3.26)
project (H5EXAMPLES C)

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
set (H5EXAMPLE_C_SRC_DIR          ${H5EXAMPLES_SOURCE_DIR}/C)
set (H5EXAMPLE_CXX_SRC_DIR        ${H5EXAMPLES_SOURCE_DIR}/CXX)
#-----------------------------------------------------------------------------
# Basic HDF5Examples stuff here
#-----------------------------------------------------------------------------
if (NOT EXAMPLES_EXTERNALLY_CONFIGURED)
  set (H5EXAMPLE_CONFIG_DIR      ${H5EXAMPLES_SOURCE_DIR}/config)
  set (H5EXAMPLE_RESOURCES_DIR   ${H5EXAMPLES_SOURCE_DIR}/config/cmake)

  include (TestBigEndian)
  if (NOT WINDOWS)
    TEST_BIG_ENDIAN (H5EXAMPLE_WORDS_BIGENDIAN)
    mark_as_advanced (H5EXAMPLE_WORDS_BIGENDIAN)
  endif ()

  include (${H5EXAMPLE_CONFIG_DIR}/HDFMacros.cmake)
  include (${H5EXAMPLE_RESOURCES_DIR}/HDFExampleMacros.cmake)
  SET_HDF_BUILD_TYPE()

  BASIC_SETTINGS (EX)

  #-----------------------------------------------------------------------------
  # HDF5 support
  #-----------------------------------------------------------------------------
  HDF5_SUPPORT (TRUE)
  APIVersion(${HDF5_VERSION} H5_LIBVER_DIR)

  #-----------------------------------------------------------------------------
  # Python support check
  #-----------------------------------------------------------------------------
  PYTHON_SUPPORT ()
endif ()
message (STATUS "HDF5 link libs: ${H5EXAMPLE_HDF5_LINK_LIBS}")
message (STATUS "HDF5 H5_LIBVER_DIR: ${H5_LIBVER_DIR} HDF5_VERSION_MAJOR: ${HDF5_VERSION_MAJOR}")

#-----------------------------------------------------------------------------
# parse the full version number from H5public.h and include in H5_VERS_INFO
#-----------------------------------------------------------------------------
if(NOT DEFINED _h5public_h_contents)
  find_file (_h5public_h H5public.h ${H5EXAMPLE_HDF5_INCLUDE_DIRS})
  mark_as_advanced (H5EXAMPLE_HDF5_INCLUDE_DIRS)
  file (READ ${_h5public_h} _h5public_h_contents)

  string (REGEX REPLACE ".*#define[ \t]+H5_VERS_MAJOR[ \t]+([0-9]*).*$"
      "\\1" H5_VERS_MAJOR ${_h5public_h_contents})
  string (REGEX REPLACE ".*#define[ \t]+H5_VERS_MINOR[ \t]+([0-9]*).*$"
      "\\1" H5_VERS_MINOR ${_h5public_h_contents})
  string (REGEX REPLACE ".*#define[ \t]+H5_VERS_RELEASE[ \t]+([0-9]*).*$"
      "\\1" H5_VERS_RELEASE ${_h5public_h_contents})
  string (REGEX REPLACE ".*#define[ \t]+H5_VERS_SUBRELEASE[ \t]+\"([0-9A-Za-z._-]*)\".*$"
      "\\1" H5_VERS_SUBRELEASE ${_h5public_h_contents})
endif ()

if (WIN32)
  set(CMAKE_TEST_LIB_DIRECTORY "${HDF5_TOOLS_DIR}")
else ()
  set(CMAKE_TEST_LIB_DIRECTORY "${HDF5_LIBRARY_PATH}")
endif ()

#-----------------------------------------------------------------------------
# Option to Enable MPI Parallel
#-----------------------------------------------------------------------------
set (CMAKE_MODULE_PATH ${H5EXAMPLE_CONFIG_DIR} ${H5EXAMPLE_RESOURCES_DIR} ${CMAKE_MODULE_PATH})
option (H5EXAMPLE_ENABLE_PARALLEL "Enable parallel build (requires MPI)" OFF)
if (H5EXAMPLE_ENABLE_PARALLEL)
  find_package(MPI REQUIRED)
  if (MPI_C_FOUND)
    set (H5_HAVE_PARALLEL 1)
  else ()
    message (WARNING "Parallel libraries not found")
  endif ()
endif ()

# Parallel IO usage requires MPI to be Linked and Included
if (H5_HAVE_PARALLEL)
  set (H5EXAMPLE_HDF5_LINK_LIBS ${H5EXAMPLE_HDF5_LINK_LIBS} ${MPI_C_LIBRARIES})
  if (MPI_C_LINK_FLAGS)
    set (CMAKE_EXE_LINKER_FLAGS "${MPI_C_LINK_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}")
  endif ()
  INCLUDE_DIRECTORIES (${MPI_C_INCLUDE_DIRS})
endif ()

set_directory_properties(PROPERTIES INCLUDE_DIRECTORIES 
    "${H5EXAMPLE_HDF5_INCLUDE_DIRS}"
)

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
option (H5EXAMPLE_BUILD_TESTING "Build HDF5 Example Testing" OFF)
if (H5EXAMPLE_BUILD_TESTING)
  set (DART_TESTING_TIMEOUT 1200 CACHE STRING
      "Timeout in seconds for each test (default 1200=20minutes)"
  )
  enable_testing ()
  include (CTest)
  include (${PROJECT_SOURCE_DIR}/CTestConfig.cmake)
  configure_file (${H5EXAMPLE_CONFIG_DIR}/CTestCustom.cmake ${PROJECT_BINARY_DIR}/CTestCustom.ctest @ONLY)
endif ()

if (${H5_LIBVER_DIR} GREATER 16)
  #-----------------------------------------------------------------------------
  # Build the HL Examples
  #-----------------------------------------------------------------------------
  option (H5EXAMPLE_BUILD_HL "Build examples HIGH Level support" OFF)

  #-----------------------------------------------------------------------------
  # Build the CPP Examples
  #-----------------------------------------------------------------------------
  if (EXISTS "${H5EXAMPLES_SOURCE_DIR}/CXX" AND IS_DIRECTORY "${H5EXAMPLES_SOURCE_DIR}/CXX")
    option (H5EXAMPLE_BUILD_CXX "Build examples C++ support" OFF)
  else ()
    set (H5EXAMPLE_BUILD_CXX OFF CACHE BOOL "Build examples C++ support" FORCE)
  endif ()

  #-----------------------------------------------------------------------------
  # Option to build filter examples
  #-----------------------------------------------------------------------------
  if (EXISTS "${H5EXAMPLES_SOURCE_DIR}/C/H5FLT" AND IS_DIRECTORY "${H5EXAMPLES_SOURCE_DIR}/C/H5FLT")
    option (H5EXAMPLE_BUILD_FILTERS "Build examples PLUGIN filter support" OFF)
    if (H5EXAMPLE_BUILD_FILTERS AND HDF5_PROVIDES_PLUGIN_SUPPORT)
      if(DEFINED ENV{HDF5_PLUGIN_PATH})
        message (STATUS "ENV PATH=$ENV{HDF5_PLUGIN_PATH}")
        set (H5EXAMPLE_HDF5_PLUGIN_PATH $ENV{HDF5_PLUGIN_PATH})
      else ()
        if(NOT DEFINED H5EXAMPLE_HDF5_PLUGIN_PATH)
          message (STATUS "LIBRARY PATH=${HDF5_LIBRARY_PATH}/plugin")
          set (H5EXAMPLE_HDF5_PLUGIN_PATH ${HDF5_LIBRARY_PATH}/plugin)
        endif ()
      endif ()
      message (STATUS "H5EXAMPLE_HDF5_PLUGIN_PATH=${H5EXAMPLE_HDF5_PLUGIN_PATH}")
    else ()
      set (H5EXAMPLE_BUILD_FILTERS OFF CACHE BOOL "Build examples PLUGIN filter support" FORCE)
    endif ()
  else ()
    set (H5EXAMPLE_BUILD_FILTERS OFF CACHE BOOL "Build examples PLUGIN filter support" FORCE)
  endif ()
else ()
  set (H5EXAMPLE_BUILD_HL OFF CACHE BOOL "Build examples High Level support" FORCE)
  set (H5EXAMPLE_BUILD_CXX OFF CACHE BOOL "Build examples C++ support" FORCE)
  set (H5EXAMPLE_BUILD_FILTERS OFF CACHE BOOL "Build examples PLUGIN filter support" FORCE)
endif ()

#-----------------------------------------------------------------------------
# Build examples
#-----------------------------------------------------------------------------
add_subdirectory (C)
if (H5EXAMPLE_BUILD_CXX AND HDF5_PROVIDES_CPP_LIB)
  add_subdirectory (CXX)
endif ()
if (H5EXAMPLE_BUILD_PYTHON)
  add_subdirectory (PYTHON)
endif ()
