cmake_minimum_required (VERSION 4.0)

foreach (required_variable IN ITEMS
    HDF5_PLATFORM_TEST_MODULE
    HDF5_PLATFORM_TEST_SYSTEM
    HDF5_PLATFORM_TEST_COMPILER_ID
)
  if (NOT DEFINED ${required_variable})
    message (FATAL_ERROR "Missing required test variable: ${required_variable}")
  endif ()
endforeach ()

# BASIC_SETTINGS is exercised in script mode so rejected compiler IDs do not
# require unsupported compilers to be installed on either validation host.
macro (ENABLE_LANGUAGE language)
  set (CMAKE_${language}_COMPILER_LOADED TRUE)
  set (CMAKE_${language}_COMPILER_ID "${HDF5_PLATFORM_TEST_COMPILER_ID}")
endmacro ()

macro (SET_HDF_OUTPUT_DIRS package_prefix)
endmacro ()

macro (target_compile_options target)
endmacro ()

macro (target_link_options target)
endmacro ()

set (CMAKE_SYSTEM_NAME "${HDF5_PLATFORM_TEST_SYSTEM}")
set (H5EXAMPLE_BUILD_CXX ON)

include ("${HDF5_PLATFORM_TEST_MODULE}")
include ("${CMAKE_CURRENT_LIST_DIR}/../../../HDF5Examples/config/cmake/HDFExampleMacros.cmake")
BASIC_SETTINGS (EX)
